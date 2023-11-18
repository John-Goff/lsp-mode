;;; lsp-emmet-lang-server.el --- lsp-mode Emmet integration -*- lexical-binding: t; -*-

;; Copyright (C) 2022 emacs-lsp maintainers

;; Author: lsp-mode maintainers
;; Keywords: lsp, emmet

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; LSP Client for Emmet using emmet-language-server

;;; Code:

(require 'lsp-mode)

(lsp-dependency 'emmet-lang-server
                '(:system "emmet-language-server")
                '(:npm :package "@olrtg/emmet-language-server"
                  :path "emmet-language-server"))

;;; emmet-lang-server
(defgroup lsp-emmet-lang-server nil
  "Settings for emmet-language-server."
  :group 'lsp-mode
  :link '(url-link "https://github.com/olrtg/emmet-language-server")
  :package-version '(lsp-mode . "8.0.1"))

(defcustom lsp-emmet-lang-server-command `(,(lsp-package-path 'emmet-lang-server) "--stdio")
  "The command and any arguments to start emmet-language-server."
  :type '(repeat :tag "List of string values" string)
  :group 'lsp-emmet-lang-server
  :package-version '(lsp-mode . "8.0.1"))

(defcustom lsp-emmet-lang-server-exclude-languages '()
  "A list of languages to not expand snippets."
  :type '(repeat :tag "Name of language" string)
  :group 'lsp-emmet-lang-server
  :package-version '(lsp-mode . "8.0.1"))

(defcustom lsp-emmet-lang-server-extensions-path '()
  "A list of paths to look for snippets.json.
See https://docs.emmet.io/customization/snippets for documentation
on writing custom snippets."
  :type '(repeat :tag "Paths" string)
  :group 'lsp-emmet-lang-server
  :package-version '(lsp-mode . "8.0.1"))

(defcustom lsp-emmet-lang-server-preferences '()
  "Preferences which are passed to emmet.
See https://docs.emmet.io/customization/preferences/ for
documentation on supported keys and their values."
  :type '(alist :tag "Emmet preferences" :key-type string :value-type sexp)
  :group 'lsp-emmet-lang-server
  :package-version '(lsp-mode . "8.0.1"))

(defcustom lsp-emmet-lang-server-variables '()
  "Variables which are used to expand snippets.
See https://docs.emmet.io/customization/snippets/#variables
for documentation on creating your own snippets and variables."
  :type '(alist :tag "Snippet variables" :key-type string :value-type string)
  :group 'lsp-emmet-lang-server
  :package-version '(lsp-mode . "8.0.1"))

(defcustom lsp-emmet-lang-server-show-abbreviation-suggestions t
  "Shows possible emmet abbreviations as suggestions.
For example, when you type li, you get suggestions for all
emmet snippets starting with li like link, link:css,
link:favicon etc. This is helpful in learning Emmet snippets
that you never knew existed unless you knew the Emmet
cheatsheet by heart.

Not applicable in stylesheets or when
`lsp-emmet-lang-server-show-expanded-abbreviation' is set to
`never'"
  :type 'boolean
  :group 'lsp-emmet-lang-server
  :package-version '(lsp-mode . "8.0.1"))

(defcustom lsp-emmet-lang-server-show-expanded-abbreviation 'always
  "Controls the Emmet suggestions that show up in the suggestion/completion list.
Allowed values are:
- `never': Never show Emmet abbreviations in the suggestion
  list for any language.
- `inMarkupAndStylesheetFilesOnly': Show Emmet suggestions
  only for languages that are purely markup and stylesheet
  based (html, pug, slim, haml, xml, xsl, css, scss, sass,
  less, stylus).
- `always': Show Emmet suggestions in all Emmet supported modes."
  :type '(choice (const :tag "Always" always)
          (const :tag "Only markup" inMarkupAndStylesheetFilesOnly)
          (const :tag "Never" never))
  :group 'lsp-emmet-lang-server
  :package-version '(lsp-mode . "8.0.1"))

(defcustom lsp-emmet-lang-server-show-suggestions-as-snippets nil
  "Shows possible emmet abbreviations as suggestions.
For example, when you type li, you get suggestions for all
emmet snippets starting with li like link, link:css,
link:favicon etc. This is helpful in learning Emmet snippets
that you never knew existed unless you knew the Emmet
cheatsheet by heart.

Not applicable in stylesheets or when
`lsp-emmet-lang-server-show-expanded-abbreviation' is set to
`never'"
  :type 'boolean
  :group 'lsp-emmet-lang-server
  :package-version '(lsp-mode . "8.0.1"))

(defcustom lsp-emmet-lang-server-syntax-profiles '()
  "Customize the output of your HTML abbreviations.
See https://docs.emmet.io/customization/syntax-profiles/#create-your-own-profile
Values should be an alist of languages and a nested alist
of options. See the above link for available options."
  :type '(alist :key-type string :value-type '(alist :key-type string :value-type string))
  :group 'lsp-emmet-lang-server
  :package-version '(lsp-mode . "8.0.1"))

(defun lsp-emmet-lang-server--init-options ()
  "Initialization options to send to emmet-language-server."
  `(:excludeLanguages ,(vconcat lsp-emmet-lang-server-exclude-languages)
    :extensionsPath ,(vconcat lsp-emmet-lang-server-extensions-path)
    :preferences ,lsp-emmet-lang-server-preferences
    :variables ,lsp-emmet-lang-server-variables
    :showAbbreviationSuggestions ,(lsp-json-bool lsp-emmet-lang-server-show-abbreviation-suggestions)
    :showExpandedAbbreviation ,lsp-emmet-lang-server-show-expanded-abbreviation
    :showSuggestionsAsSnippets ,(lsp-json-bool lsp-emmet-lang-server-show-suggestions-as-snippets)
    :syntaxProfiles ,lsp-emmet-lang-server-syntax-profiles))

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection (lambda () lsp-emmet-lang-server-command))
  :activation-fn (lsp-activate-on "html" "css" "scss" "sass" "less" "javascriptreact" "typescriptreact" "vue" "svelte")
  :priority -1
  :add-on? t
  :multi-root t
  :server-id 'emmet-lang-server
  :initialization-options #'lsp-emmet-lang-server--init-options
  :download-server-fn (lambda (_client callback error-callback _update?)
                        (lsp-package-ensure 'emmet-lang-server callback error-callback))))

(lsp-consistency-check lsp-emmet-lang-server)

(provide 'lsp-emmet-lang-server)
;;; lsp-emmet-lang-server.el ends here
