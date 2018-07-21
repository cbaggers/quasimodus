(in-package #:quasimodus)

#||

Given the research below I think we can realistically provide two things

1. Normalize a form containing backquote, comma, etc symbols into the form
   used by ccl

2. Normalize a 'pattern' into a form ammenable for consuming by libs that
   way to match structure. We can limit what forms are in the unquoted sections
   to make it tractable (otherwise we have to handle arbitrary code)

   `((,a b) ,b ,_ #(1 2 ,c) ,@foo )

||#

;;------------------------------------------------------------

;; Support Checklist
;; 
;; [√] ABCL
;; [ ] Allegro CL - 32bit grr
;; [√] Clasp - used docker
;; [√] Clozure CL
;; [√] CLISP - used docker
;; [√] CMUCL - used docker
;; [√] ECL
;; [ ] LispWorks - It doesnt
;; [√] MKCL
;; [√] SBCL
;; [ ] Scieneer CL - website down

;; Try:
;; '`(foo )
;; '`(fo bar ,baz ,(+ 1 2) )

;;------------------------------------------------------------

#+sbcl
(progn
  (defun quasiquoted-p (form)
    (and (listp form)
         (eq (first form) 'sb-int:quasiquote)))

  (defun quasiquoted-form (quasiquoted-form)
    (second quasiquoted-form))

  (defun unquoted-p (form)
    (typep form 'sb-impl::comma))

  (defun unquoted-form (form)
    (sb-impl::comma-expr form)))

;;------------------------------------------------------------

#+ecl
(progn
  (defun quasiquoted-p (form)
    (and (listp form)
         (eq (first form) 'si:quasiquote)))

  (defun quasiquoted-form (quasiquoted-form)
    (second quasiquoted-form))

  (defun unquoted-p (form)
    (and (listp form)
         (eq (first form) 'SI:UNQUOTE)))

  (defun unquoted-form (form)
    (second form)))

;;------------------------------------------------------------
;; ccl does this:
;;
;; '`(fo bar ,baz `(hey) `(a ,jam) ,(+ 1 2))

;; (LIST* (QUOTE FO)
;;        (LIST* (QUOTE BAR)
;;               (LIST* BAZ
;;                      (LIST* (QUOTE (QUOTE (HEY)))
;;                             (LIST* (QUOTE (LIST* (QUOTE A) (LIST JAM)))
;;                                    (LIST (+ 1 2)))))))
;;
;;
;; which is a pain in the dick as it doesnt maintain the original structure
;; in any way

;;------------------------------------------------------------
;; abcl
;;
;; '`(fo bar ,baz `(hey) `(a ,jam) ,(+ 1 2))
;;
;; (SYSTEM::BACKQ-LIST (QUOTE FO)
;;                     (QUOTE BAR)
;;                     BAZ
;;                     (QUOTE (QUOTE (HEY)))
;;                     (QUOTE (SYSTEM::BACKQ-LIST (QUOTE A) JAM))
;;                     (+ 1 2))

;;------------------------------------------------------------
;; cmucl
;;
;; '`(fo bar ,baz `(hey) `(a ,jam) ,(+ 1 2))
;;
;; Note: (setf *print-pretty* nil) before eval'ing above
;;
;; (LISP::BACKQ-LIST (QUOTE FO)
;;                   (QUOTE BAR)
;;                   BAZ
;;                   (QUOTE (QUOTE (HEY)))
;;                   (QUOTE (LISP::BACKQ-LIST (QUOTE A) JAM))
;;                   (+ 1 2))

;;------------------------------------------------------------
;; clisp
;; '`(fo bar ,baz `(hey) `(a ,jam) ,(+ 1 2))
;;
;; Note: (setf *print-pretty* nil) didnt work so had to map #'print
;; and reassemble.
;;

;; this looks fucky
;; (SYSTEM::BACKQUOTE 
;;  (FO 
;;   BAR 
;;   (SYSTEM::UNQUOTE BAZ) 
;;   (SYSTEM::BACKQUOTE (HEY))
;;   (SYSTEM::BACKQUOTE (A (SYSTEM::UNQUOTE JAM)))
;;   (SYSTEM::UNQUOTE (+ 1 2))))

;;------------------------------------------------------------
;; clasp
;; '`(fo bar ,baz `(hey) `(a ,jam) ,(+ 1 2))
;;
;; Note: (setf *print-pretty* nil) didnt work so had to map #'print
;; and reassemble.
;;
;;
;; (BACKQUOTE
;;  (FO
;;   BAR
;;   (CORE::UNQUOTE BAZ)
;;   (BACKQUOTE (HEY))
;;   (BACKQUOTE (A (CORE::UNQUOTE JAM)))
;;   (CORE::UNQUOTE (+ 1 2))))

;;------------------------------------------------------------
;; MKCL
;;
;; '`(fo bar ,baz `(hey) `(a ,jam) ,(+ 1 2))
;;
;; Note: (setf *print-pretty* nil) didnt work so had to map #'print
;; and reassemble.
;;
;; (SI:QUASIQUOTE (FO
;;                 BAR
;;                 (SI:UNQUOTE BAZ)
;;                 (SI:QUASIQUOTE (HEY))
;;                 (SI:QUASIQUOTE (A (SI:UNQUOTE JAM)))
;;                 (SI:UNQUOTE (+ 1 2)))) 

;;------------------------------------------------------------
