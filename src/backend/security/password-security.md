# Password Security

Password security covers how passwords are stored, validated, and managed. Poor password handling is one of the most common causes of data breaches.

## Hashing

**Password hashing** is the process of converting a password into a fixed-length, irreversible string using a one-way function.

- Never store passwords in plaintext
- Never encrypt passwords -- hashing is one-way, encryption is reversible
- Use dedicated password hashing algorithms, not general-purpose hash functions (MD5, SHA-256)
- Password hashing algorithms are intentionally slow to resist brute-force attacks

## Salting

A **salt** is a unique, random value added to each password before hashing.

```text
hash = password_hash(password + salt)
```

- Each user gets a unique salt, even if two users have the same password
- Salts are stored alongside the hash, not kept secret
- Salting prevents rainbow table attacks (precomputed hash lookups)
- Modern password hashing algorithms (bcrypt, Argon2) include salting internally

## bcrypt

**bcrypt** is a password hashing algorithm based on the Blowfish cipher.

Features:

- Built-in salt generation
- Configurable cost factor (work factor) that increases over time
- Resistant to GPU and ASIC attacks due to memory-hard properties
- Default cost factor of 10-12 is recommended (as of 2024)

```python
# Python example
import bcrypt

hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))
bcrypt.checkpw(password.encode(), hashed)
```

Work factor recommendations:

| Year | Recommended rounds |
|---|---|
| 2020 | 10-12 |
| 2024 | 12-14 |
| Future | Increase as hardware improves |

## Argon2

**Argon2** won the Password Hashing Competition (2015) and is considered the modern standard for password hashing.

Variants:

- **Argon2d** -- data-dependent memory access, resistant to GPU cracking
- **Argon2i** -- data-independent memory access, resistant to side-channel attacks
- **Argon2id** -- hybrid, recommended for most use cases

Configurable parameters:

- **Memory cost** -- amount of RAM required (e.g., 64 MB - 1 GB)
- **Time cost** -- number of iterations
- **Parallelism** -- number of threads

```python
# Python example
from argon2 import PasswordHasher

ph = PasswordHasher(
    time_cost=3,
    memory_cost=65536,  # 64 MB
    parallelism=4
)
hashed = ph.hash(password)
ph.verify(hashed, password)
```

Argon2 is preferred over bcrypt for new applications because it is more resistant to GPU attacks and allows fine-tuning of memory usage.

## Password Policies

Password policies define rules for creating and managing passwords.

Common policies:

- **Minimum length** -- at least 12-16 characters (length matters more than complexity)
- **Maximum length** -- allow at least 64-128 characters (support passphrases)
- **No arbitrary complexity rules** -- avoid forcing uppercase, numbers, symbols (NIST SP 800-63B)
- **Check against breached password databases** -- reject passwords found in known breaches
- **No mandatory periodic rotation** -- rotate only on suspicion of compromise (NIST SP 800-63B)
- **Support paste** -- allow users to use password managers
- **Rate limit login attempts** -- lockout or throttle after failed attempts
- **MFA for high-value accounts** -- require multi-factor authentication for admin or sensitive operations

Modern guidelines (NIST SP 800-63B):

- Passwords should be at least 8 characters (12+ recommended)
- Support all printable characters including spaces
- Do not require composition rules (uppercase, symbols, etc.)
- Check passwords against known breach databases
- Do not use secret questions as a recovery mechanism

## Comparison

| Algorithm | Speed | Memory-hard | Year | Recommendation |
|---|---|---|---|---|
| MD5 | Very fast | No | 1991 | Never use for passwords |
| SHA-256 | Fast | No | 2001 | Never use for passwords |
| bcrypt | Moderate | Partially | 1999 | Still acceptable |
| scrypt | Moderate | Yes | 2009 | Good alternative |
| Argon2 | Configurable | Yes | 2015 | Recommended |

## Mid/Senior Interview Questions and Answers

### 1. Why should you never use MD5 or SHA-256 for password hashing?

**Answer:** MD5 and SHA-256 are fast hash functions designed for data
integrity, not password storage. Their speed makes brute-force and rainbow
table attacks trivially fast with modern GPUs.

Password hashing algorithms (bcrypt, Argon2) are intentionally slow and
configurable. They add salt, use multiple rounds, and can be tuned to resist
hardware-accelerated attacks.

### 2. What is the difference between salting and peppering?

**Answer:** A salt is a unique random value stored alongside the hash. It
prevents rainbow table attacks by ensuring identical passwords produce different
hashes.

A pepper is a secret value added to the password before hashing, stored
separate from the database (environment variable, HSM). If the database is
leaked, the pepper adds an additional layer of protection.

However, peppers add operational complexity and are not a substitute for proper
hashing algorithms.

### 3. How do you handle password migration from a weak algorithm?

**Answer:** Do not attempt to reverse hashes. Instead, use a transparent
upgrade strategy:

1. On next login, hash the submitted password with the old algorithm.
2. Verify against the stored hash.
3. Re-hash with the new algorithm (Argon2) and update the stored hash.
4. For users who have not logged in, require a password reset.

This avoids a disruptive forced reset while migrating all passwords over time.

### 4. Why does NIST recommend against mandatory password rotation?

**Answer:** Forced periodic rotation leads to predictable patterns (Password1,
Password2, etc.) and encourages users to write down passwords or use weak
variations.

NIST SP 800-63B recommends rotating passwords only when there is evidence of
compromise. Instead, focus on checking against breach databases, supporting
long passwords, and requiring MFA.

### 5. Why is Argon2 preferred over bcrypt for new applications?

**Answer:** Argon2 is memory-hard, meaning it requires significant RAM during
hashing. This makes GPU and ASIC attacks much more expensive compared to
bcrypt, which is partially memory-hard.

Argon2 also provides fine-grained control over memory, time, and parallelism
costs, making it easier to tune for current hardware capabilities. It won the
Password Hashing Competition and is the modern standard.
