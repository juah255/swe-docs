# Design Patterns

**Design patterns** are reusable solutions to common problems in software design.
They are not code you copy directly. They are proven approaches that describe how
objects and classes can collaborate to solve a recurring problem in a flexible,
maintainable way.

A pattern gives a shared vocabulary. Saying "use a `Strategy` here" communicates
intent faster than describing the mechanics each time.

## When to use them

Use a pattern when it makes change **easier** than the alternative. Good signals
include:

- A variation point that will realistically grow (new payment methods, new export
  formats).
- A boundary that needs substitution for testing (repositories, gateways, clocks).
- Duplicated control flow that a pattern can centralize.

## The risk of overuse

Patterns add **indirection**. Every interface, factory, or extra layer is a cost
in files, navigation, and debugging. Applying a pattern before the variation is
real produces abstract code that is harder to read than a plain function.

A useful rule:

```text
Reach for a pattern when you feel the pain of change,
not in anticipation of pain that may never come.
```

Senior engineers use patterns to manage real complexity, not to make code look
more formal.

## The three categories

The classic Gang of Four patterns fall into three groups based on what they solve.

| Category | Concern | Examples |
| --- | --- | --- |
| **Creational** | How objects are created | Singleton, Factory Method, Abstract Factory, Builder, Prototype |
| **Structural** | How objects are composed | Adapter, Decorator, Facade, Proxy, Composite, Bridge |
| **Behavioral** | How objects interact and share responsibility | Strategy, Observer, Command, Template Method, State, Iterator, Chain of Responsibility |

### Creational

Focused on **flexible and decoupled object creation**.

- **Singleton**: a single shared instance.
- **Factory Method**: a method decides which concrete class to create.
- **Abstract Factory**: create families of related objects.
- **Builder**: assemble a complex object step by step.
- **Prototype**: create new objects by cloning existing ones.

### Structural

Focused on **composing objects into larger structures**.

- **Adapter**: make an incompatible interface usable.
- **Decorator**: add behavior without changing the original class.
- **Facade**: provide a simple interface over a complex subsystem.
- **Proxy**: control access to another object.
- **Composite**: treat individual objects and groups uniformly.
- **Bridge**: separate an abstraction from its implementation.

### Behavioral

Focused on **communication and responsibility between objects**.

- **Strategy**: interchangeable algorithms behind one interface.
- **Observer**: notify listeners when state changes.
- **Command**: package a request as an object.
- **Template Method**: define a skeleton, let subclasses fill steps.
- **State**: change behavior when internal state changes.
- **Iterator**: traverse a collection without exposing its structure.
- **Chain of Responsibility**: pass a request along a chain of handlers.

## Subtopic pages

Each category has its own page with intent, when to use, backend examples, and
trade-offs:

- [Creational Patterns](creational.md)
- [Structural Patterns](structural.md)
- [Behavioral Patterns](behavioral.md)
- [Design Patterns Questions](questions.md)

## Mid/Senior Interview Questions and Answers

### 1. How do you decide whether to introduce a design pattern?

**Answer:** Introduce a pattern when there is a real, recurring variation or a
boundary that benefits from substitution. The pattern should reduce the cost of
the next change you expect to make.

If you cannot name the concrete change the pattern enables, you probably do not
need it yet. Plain code that is easy to read beats a premature abstraction.

### 2. What is the main risk of overusing patterns?

**Answer:** Overuse adds indirection: more interfaces, more files, and longer
call chains that hide simple logic. Debugging gets harder because behavior is
spread across many small pieces.

The cost is paid every time someone reads the code, while the benefit only
appears if the variation actually materializes. Favor simplicity until the
pressure to change is real.

### 3. How are the three pattern categories different?

**Answer:** Creational patterns deal with how objects are created, helping
decouple construction from use. Structural patterns deal with how objects are
composed into larger structures. Behavioral patterns deal with how objects
communicate and divide responsibility at runtime.

Knowing the category helps you locate the right tool: a creation problem rarely
needs a behavioral pattern, and vice versa.

### 4. Are patterns still relevant with modern frameworks?

**Answer:** Yes, but many are now built into frameworks and languages. Dependency
injection containers, middleware pipelines, and event systems are patterns
provided for you.

The value today is recognizing these patterns inside the tools you already use,
and applying the remaining ones deliberately where the framework does not.
