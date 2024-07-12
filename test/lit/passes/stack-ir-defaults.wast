;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.

;; Request StackIR explicitly. This optimizes.
;; RUN: wasm-opt %s --generate-stack-ir --optimize-stack-ir -all               --print-stack-ir | filecheck %s --check-prefix=REQUESTED

;; As above, but disallow it later. This does not optimize.
;; RUN: wasm-opt %s --generate-stack-ir --optimize-stack-ir -all --no-stack-ir --print-stack-ir | filecheck %s --check-prefix=DISALLOWD

;; As above, but flip it, so we allow it after disallowing. This optimizes.
;; RUN: wasm-opt %s --no-stack-ir --generate-stack-ir --optimize-stack-ir -all --print-stack-ir | filecheck %s --check-prefix=REALLOWED

;; Running -O will use StackIR by default. This optimizes.
;; RUN: wasm-opt %s -O               -all --print-stack-ir | filecheck %s --check-prefix=O_DEFAULT

;; As above, but disallow it. This does not optimize.
;; RUN: wasm-opt %s -O --no-stack-ir -all --print-stack-ir | filecheck %s --check-prefix=O__DENIED

;; As above, but flip it. This still does not optimize, as the global state of
;; --no-stack-ir is not overridden (before we explicitly overrode it, while here
;; we -O only requests StackIR if allowed).
;; RUN: wasm-opt %s --no-stack-ir -O -all --print-stack-ir | filecheck %s --check-prefix=O_REALLOW

(module
  ;; REQUESTED:      (import "a" "b" (func $import (type $0) (result i32)))
  ;; DISALLOWD:      (import "a" "b" (func $import (type $0) (result i32)))
  ;; REALLOWED:      (import "a" "b" (func $import (type $0) (result i32)))
  ;; O_DEFAULT:      (import "a" "b" (func $import (type $0) (result i32)))
  ;; O__DENIED:      (import "a" "b" (func $import (type $0) (result i32)))
  ;; O_REALLOW:      (import "a" "b" (func $import (type $0) (result i32)))
  (import "a" "b" (func $import (result i32)))

  ;; REQUESTED:      (func $func (type $0) (result i32)
  ;; REQUESTED-NEXT:  call $import
  ;; REQUESTED-NEXT:  unreachable
  ;; REQUESTED-NEXT: )
  ;; DISALLOWD:      (func $func (type $0) (result i32)
  ;; DISALLOWD-NEXT:  call $import
  ;; DISALLOWD-NEXT:  drop
  ;; DISALLOWD-NEXT:  unreachable
  ;; DISALLOWD-NEXT: )
  ;; REALLOWED:      (func $func (type $0) (result i32)
  ;; REALLOWED-NEXT:  call $import
  ;; REALLOWED-NEXT:  unreachable
  ;; REALLOWED-NEXT: )
  ;; O_DEFAULT:      (func $func (type $0) (result i32)
  ;; O_DEFAULT-NEXT:  call $import
  ;; O_DEFAULT-NEXT:  unreachable
  ;; O_DEFAULT-NEXT: )
  ;; O__DENIED:      (func $func (type $0) (result i32)
  ;; O__DENIED-NEXT:  call $import
  ;; O__DENIED-NEXT:  drop
  ;; O__DENIED-NEXT:  unreachable
  ;; O__DENIED-NEXT: )
  ;; O_REALLOW:      (func $func (type $0) (result i32)
  ;; O_REALLOW-NEXT:  call $import
  ;; O_REALLOW-NEXT:  drop
  ;; O_REALLOW-NEXT:  unreachable
  ;; O_REALLOW-NEXT: )
  (func $func (export "func") (result i32)
    ;; This drop can be removed when we optimize using StackIR.
    (drop
      (call $import)
    )
    (unreachable)
  )
)