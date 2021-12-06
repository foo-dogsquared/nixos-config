;;; tools/wiki/config.el --- The configuration for foo-dogsquared's wiki as a module.
;;; -*- lexical-binding: t; -*-

;;; Commentary:
;; My custom configuration for setting up my personal wiki.
;; Also a good opportunity for training my Elisp-fu.
(require 'f)

;; Code
(defvar +wiki-directory "~/wiki")

(defun +org-roam-split-to-random-node ()
  "Open a split window sensibly for a random note."
  ; TODO: Create a window, open a random note, and that's it.
  (interactive)
  (split-window-sensibly)
  (other-window 1)
  (org-roam-node-random))

(when (featurep! +biblio)
  (defvar +wiki-references-filename "references.bib")
  (defvar +wiki-bibliography-note-filename "references.org")
  (defvar +wiki-bibliography-file (f-join +wiki-directory +wiki-references-filename))
  (defvar +wiki-bibliography-note (f-join +wiki-directory +wiki-bibliography-note-filename))

  (defun +wiki/biblio-setup ()
    "Setup the variables for the wiki config."
    (setq +wiki-bibliography-file (f-join +wiki-directory +wiki-references-filename)
          +wiki-bibliography-note (f-join +wiki-directory +wiki-bibliography-note-filename)
          org-cite-global-bibliography `(,+wiki-bibliography-file)
          org-ref-default-bibliography +wiki-bibliography-file
          org-ref-bibliography-notes +wiki-bibliography-note
          bibtex-completion-bibliography +wiki-bibliography-file
          bibtex-completion-notes-path +wiki-directory))

  (use-package! org-roam-bibtex
    :after org-roam
    :preface
    :config
    (require 'org-ref)
    (+wiki/biblio-setup)))

(when (featurep! +anki)
  (defvar +anki-cards-directory-name "cards")
  (defvar +anki-cards-directory (f-join +wiki-directory +anki-cards-directory-name))
  (defun +anki-editor-push-all-notes-to-anki ()
    (interactive)
    (anki-editor-push-notes nil nil (directory-files-recursively +anki-cards-directory "\\.*org" nil)))
  (defun +anki-editor-reset-note ()
    "Reset the Anki note in point by deleting the note ID and the deck."
    (interactive)
    (org-entry-delete (point) anki-editor-prop-note-id)
    (org-entry-delete (point) anki-editor-prop-deck))
  (defun +anki-editor-reset-all-notes ()
    "Reset the Anki notes in the current buffer by deleting the note ID and the deck."
    (interactive)
    (anki-editor-map-note-entries #'+anki-editor-reset-note))

  (use-package! anki-editor
    :hook (org-mode . anki-editor-mode)
    :preface
    (defvar +wiki-directory nil)
    :init
    (map! :localleader
          :map org-roam-mode-map
          (:prefix ("C" . "Anki cards")
           :desc "Push all cards in current document" :n "p" #'anki-editor-push-notes
           :desc "Push all cards in cards directory to Anki" :n "P" #'+anki-editor-push-all-notes-to-anki
           :desc "Retry to push failed cards" :n "r" #'anki-editor-retry-failure-notes
           :desc "Insert a card in current document" :n "i" #'anki-editor-insert-note
           :desc "Create a cloze region" :n "I" #'anki-editor-cloze-region
           :desc "Export the subtree as HTML" :n "e" #'anki-editor-export-subtree-to-html
           :desc "Remove all anki-editor-related properties in a card" :n "d" #'+anki-editor-reset-note
           :desc "Remove all properties in all notes" :n "D" #'+anki-editor-reset-all-notes))
    :config
    (setq anki-editor-create-decks 't
          +anki-cards-directory (f-join +wiki-directory +anki-cards-directory-name))))

(when (featurep! +dendron)
  (use-package! dendroam
    :after org-roam))

(when (featurep! +graph)
  (use-package! websocket
    :after org-roam)

  (use-package! org-roam-ui
    :after org-roam
    :hook (org-roam . org-roam-ui-mode)))

;;; config.el ends here
