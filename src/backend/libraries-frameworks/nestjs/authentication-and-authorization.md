# Authentication & Authorization

Authentication verifies *who* you are. Authorization verifies *what* you are allowed to do. In NestJS these are implemented with guards, JWT, roles, and permissions.

## Authentication vs authorization

- **Authentication** - prove identity (login, verify token, check password).
- **Authorization** - decide whether an authenticated identity may access a resource (roles, permissions, ownership).

Authentication happens first. Its result (usually a user object) is attached to the request, and authorization rules read from it.

## Password hashing

Never store plain-text passwords. Use a slow, salted hash.

```bash
npm i bcrypt
```

```ts
import * as bcrypt from 'bcrypt';

const salt = await bcrypt.genSalt(10);
const hash = await bcrypt.hash(password, salt);

// verify
const ok = await bcrypt.compare(password, storedHash);
```

Use `argon2` or `bcrypt` (never MD5/SHA1/SHA256 for passwords). Consider rate limiting the login endpoint to slow down brute force.

## JWT

JWT (JSON Web Token) is a signed, self-contained token: `header.payload.signature`.

```bash
npm i @nestjs/jwt
```

Register the module:

```ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';

@Module({
  imports: [
    JwtModule.register({
      global: true,
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '15m' },
    }),
  ],
})
export class AuthModule {}
```

Sign and verify:

```ts
const token = await this.jwtService.signAsync({ sub: user.id, role: user.role });

const payload = await this.jwtService.verifyAsync(token); // throws if invalid/expired
```

## Access tokens

The access token proves the user's identity for API calls. It is short-lived (minutes) and sent with every request, usually as `Authorization: Bearer <token>`.

```ts
async login(dto: LoginDto) {
  const user = await this.usersService.findByEmail(dto.email);
  const valid = await bcrypt.compare(dto.password, user.password);
  if (!valid) throw new UnauthorizedException();

  const payload = { sub: user.id, role: user.role };
  return { access_token: await this.jwtService.signAsync(payload) };
}
```

## Refresh tokens

A refresh token is long-lived (days/weeks) and used only to mint new access tokens. It must be stored and revocable.

```ts
async refresh(refreshToken: string) {
  const payload = await this.jwtService.verifyAsync(refreshToken, {
    secret: process.env.JWT_REFRESH_SECRET,
  });
  // rotate: issue a new pair, invalidate the old refresh token
  const newAccess = await this.jwtService.signAsync(
    { sub: payload.sub, role: payload.role },
    { expiresIn: '15m' },
  );
  return { access_token: newAccess };
}
```

Best practice: store refresh tokens hashed in the database, allow rotation, and revoke on logout.

## Guards

A guard determines whether a request is allowed to access a specific route by evaluating conditions such as authentication or authorization before the route handler is executed.

```ts
import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);

    if (!token) throw new UnauthorizedException();

    try {
      const payload = await this.jwtService.verifyAsync(token);
      request['user'] = payload; // attach identity for later use
    } catch {
      throw new UnauthorizedException();
    }
    return true;
  }

  private extractToken(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
```

Apply it:

```ts
@UseGuards(AuthGuard)
@Controller('users')
export class UsersController {}
```

## Custom guards

For custom logic (API keys, IP allowlists, subscription status), implement `CanActivate`:

```ts
@Injectable()
export class ApiKeyGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    return request.headers['x-api-key'] === process.env.API_KEY;
  }
}
```

## Roles

Roles are coarse-grained flags on the user (admin, user, moderator). Role-based access control (RBAC) checks whether the request user's role is allowed.

Create a `Roles` decorator and a `RolesGuard`:

```ts
import { SetMetadata } from '@nestjs/common';
import { Role } from './role.enum';

export const Roles = (...roles: Role[]) => SetMetadata('roles', roles);
```

```ts
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles?.length) return true;

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.includes(user.role);
  }
}
```

Use both:

```ts
@Post()
@Roles(Role.Admin)
@UseGuards(AuthGuard, RolesGuard)
create() {}
```

## Permissions

Permissions are finer-grained than roles (e.g. `users:delete`, `orders:update`). Combine a role with a permission set, or map roles to permissions.

```ts
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<string[]>('permissions', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!required) return true;

    const { user } = context.switchToHttp().getRequest();
    return required.every((p) => user.permissions.includes(p));
  }
}
```

Prefer checking *permission* over *role* in the guard, because permission checks survive role renames.

## @CurrentUser() type decorators

Create a decorator to read the authenticated user from the request:

```ts
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const CurrentUser = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return data ? request.user?.[data] : request.user;
  },
);
```

```ts
@Get('me')
me(@CurrentUser() user: JwtPayload) {
  return user;
}
```

## Cookies

Store the access or refresh token in an `HttpOnly` cookie to reduce XSS risk:

```ts
import { Response } from 'express';

async login(@Body() dto: LoginDto, @Res({ passthrough: true }) res: Response) {
  const { access_token } = await this.authService.login(dto);
  res.cookie('access_token', access_token, {
    httpOnly: true,
    sameSite: 'strict',
    secure: process.env.NODE_ENV === 'production',
    maxAge: 15 * 60 * 1000,
  });
  return { ok: true };
}
```

`HttpOnly` prevents JavaScript from reading the cookie, and `secure` sends it only over HTTPS.

## Sessions

Session-based auth stores the session on the server (database or Redis) and sends the client a session ID cookie. It is easy to revoke but requires server-side storage.

```ts
// pseudocode with a session store
const session = await sessionStore.create(user.id);
res.cookie('sid', session.id, { httpOnly: true });
```

Use sessions when you need immediate revocation, or JWTs when you want stateless, horizontally scalable auth without server-side lookups.

## OAuth basics

OAuth 2.0 lets users authenticate through a third party (Google, GitHub).

```bash
npm i @nestjs/passport passport passport-google-oauth20
```

The authorization-code flow:

1. User clicks "Login with Google".
2. App redirects to Google with `client_id` and `redirect_uri`.
3. Google redirects back with an authorization `code`.
4. App exchanges the code for tokens via Google's token endpoint.
5. App verifies the identity and issues its own JWT.

Use `@nestjs/passport` strategies for OAuth providers. After successful OAuth, link the external identity to a local user and issue your own JWT.

## When to use Guard, Interceptor, Middleware, Pipe, and Exception Filter

| Hook | Purpose | Typical use |
|------|---------|-------------|
| **Middleware** | Runs before guards; raw access to request/response | Logging, CORS, parsing, JWT extraction for analytics |
| **Guard** | Decision gate for routes | Authentication, role/permission checks |
| **Interceptor** | Wrap handler execution | Logging, caching, response mapping, timing |
| **Pipe** | Validate/transform input | DTO validation, param parsing |
| **Exception Filter** | Catch and format errors | Consistent error responses, logging errors |

Rule of thumb: middleware for infrastructure concerns at the transport level, guards for authorization decisions, pipes for input, interceptors for cross-cutting output, and filters for errors.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between authentication and authorization?

**Answer:** Authentication proves identity - who the user is - usually by
verifying a password, JWT, or session. Authorization decides what that identity
may do - which routes or resources it can access - using roles or permissions.
Authentication always runs first and produces the identity that authorization
reads.

### 2. Why are access and refresh tokens separate?

**Answer:** Short-lived access tokens (minutes) limit the damage if stolen and
are verified locally without a database lookup. Refresh tokens (days/weeks) let
the client silently get a new access token when it expires. Refresh tokens are
stored and rotated server-side so they can be revoked.

If you had a single long-lived token, a leak grants access until expiry with no
way to revoke.

### 3. How do guards know what roles are required?

**Answer:** The `Roles` decorator writes metadata with `SetMetadata`, and the
`RolesGuard` reads it with the `Reflector` (`getAllAndOverride` across handler
and class). The guard then compares the required roles with the authenticated
user's role. Guards do not know routes directly; they rely on this metadata.

### 4. What are the trade-offs of JWT vs sessions?

**Answer:** JWTs are stateless: the server verifies the signature locally, which
scales horizontally without shared storage. But they cannot be revoked easily and
payload size grows. Sessions are server-side, trivially revocable, but require a
session store and a lookup per request.

Many systems combine them: a short-lived JWT for API calls plus a revocable
refresh token or session for renewals.

### 5. What is the safest way to store tokens in the browser?

**Answer:** Store tokens in `HttpOnly` cookies so JavaScript cannot read them,
reducing XSS token theft. Use `Secure`, `SameSite`, and short expiry. If you must
keep a token in JavaScript memory (SPA flows), keep it in memory rather than
localStorage to reduce the exposure surface.