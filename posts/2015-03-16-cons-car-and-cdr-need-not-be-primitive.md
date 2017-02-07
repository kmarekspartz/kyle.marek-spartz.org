---
title: cons, car, and cdr need not be primitive
tags: haskell-mn, programming-languages, lisp
description: An exercise from SICP
---

A [lisp](https://en.wikipedia.org/wiki/Lisp_(programming_language)) can be
implemented using a small set of primitives from which other lisp features can
be derived. The set is not fixed; different lisps use different primitives.
`cons`, `car`, and `cdr` are often primitives, but they do not need to be.


### Primitive `cons`, `car`, and `cdr`

Typical implementations of `cons`, `car`, and `cdr` use an underlying array
representations in their host environment. In a JavaScript host environment,
this could look like:

``` javascript
var cons = function (head, tail) {
  return [head, tail];
};

var car = function (pair) {
  return pair[0];
};

var cdr = function (pair) {
  return pair[1];
};
```


### Derived `cons`, `car`, and `cdr`

To implement `cons`, `car`, and `cdr` as derived features, the lisp should only
need function definitions and lambdas as features (either derived or primitive).

``` scheme
(define (cons head tail)
  (lambda (f) (f head tail))

(define (car pair)
  (pair (lambda (head tail) head)))

(define (cdr pair)
  (pair (lambda (head tail) tail)))
```

This could compile down into:

```javascript
var cons = function (head, tail) {
  return function (f) {
    return f(head, tail);
  };
};

var car = function (pair) {
  return pair(
    function (head, tail) { return head; }
  );
};

var cdr = function (pair) {
  return pair(
    function (head, tail) { return tail; }
  );
};
```

*See also:* [SICP Exercise
2.4](https://mitpress.mit.edu/sicp/full-text/book/book-Z-H-14.html#%25_thm_2.4)
