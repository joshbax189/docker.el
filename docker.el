;;; docker.el --- Emacs interface to Docker  -*- lexical-binding: t -*-

;; Author: Philippe Vaucher <philippe.vaucher@gmail.com>
;; URL: https://github.com/Silex/docker.el
;; Keywords: filename, convenience
;; Version: 2.0.0
;; Package-Requires: ((aio "1.0") (dash "2.19.1") (docker-tramp "0.1") (emacs "26.1") (json-mode "1.8.0") (s "1.12.0") (tablist "1.0") (transient "0.3.7"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This package allows you to manipulate docker images, containers & more from Emacs.

;;; Code:

(require 'docker-compose)
(require 'docker-container)
(require 'docker-image)
(require 'docker-network)
(require 'docker-volume)

(defun docker-read-log-level (prompt &rest _args)
  "Read the docker log level using PROMPT."
  (completing-read prompt '(debug info warn error fatal)))

(defun docker-read-certificate (prompt &optional initial-input _history)
  "Wrapper around `read-file-name'."
  (read-file-name prompt nil nil t initial-input (apply-partially 'string-match ".*\\.pem")))

(defvar docker-open-hook ()
  "Called when Docker transient is openened.")

(defvar docker-status-strings '(:containers "" :images "" :networks "" :volumes "")
  "Plist of statuses for `docker-transient'.")

;;;###autoload (autoload 'docker "docker" nil t)
(transient-define-prefix docker ()
  "Transient for docker."
  :man-page "docker"
  ["Arguments"
   (5 "H" "Host" "--host " read-string)
   (5 "Tt" "TLS" "--tls")
   (5 "Tv" "TLS verify remote" "--tlsverify")
   (5 "Ta" "TLS CA" "--tlscacert" docker-read-certificate)
   (5 "Tc" "TLS certificate" "--tlscert" docker-read-certificate)
   (5 "Tk" "TLS key" "--tlskey" docker-read-certificate)
   (5 "l" "Log level" "--log-level " docker-read-log-level)]
  ["Docker"
   ("c" (lambda ()(plist-get docker-status-strings :containers)) docker-containers)
   ("i" (lambda ()(plist-get docker-status-strings :images))     docker-images)
   ("n" (lambda ()(plist-get docker-status-strings :networks))   docker-networks)
   ("v" (lambda ()(plist-get docker-status-strings :volumes))    docker-volumes)]
  ["Other"
   ("C" "Compose"    docker-compose)]
  (interactive)
  (run-hooks 'docker-open-hook)
  (transient-setup 'docker))

(provide 'docker)

;;; docker.el ends here
