;; -*- no-byte-compile: t; -*-
;;; tools/wiki/packages.el

;; The main package for creating a wiki.
(package! org-roam
  :recipe (:host github :repo "org-roam/org-roam"))

(when (featurep! +biblio)
  (package! org-ref
    :recipe (:host github :repo "jkitchin/org-ref"))
  (package! org-roam-bibtex
    :recipe (:host github :repo "org-roam/org-roam-bibtex")))

(when (featurep! +anki)
  (package! anki-editor
    :recipe (:host github
             :repo "louietan/anki-editor")
    :pin "546774a453ef4617b1bcb0d1626e415c67cc88df"))

(when (featurep! +markdown)
  (package! md-roam
    :recipe (:host github :repo "nobiot/md-roam" :branch "v2")))

(when (featurep! +dendron)
  (package! dendroam
    :recipe (:host github :repo "vicrdguez/dendroam")))

(when (featurep! +graph)
  (package! simple-httpd)
  (package! websocket)
  (package! org-roam-ui
    :recipe (:host github :repo "org-roam/org-roam-ui" :files ("*.el" "out"))))
