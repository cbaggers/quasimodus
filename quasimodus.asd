;;;; quasimodus.asd

(asdf:defsystem #:quasimodus
  :description "A few helpers over different implementation's representations of quasiquotation"
  :author "Chris Bagley (Baggers) <techsnuffle@gmail.com>"
  :license "BSD 2 Clause"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "quasimodus")))
