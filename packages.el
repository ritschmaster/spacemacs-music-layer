;;; packages.el --- music layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Richard Paul Bäck <richard.baeck@free-your-pc.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `music-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `music/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `music/pre-init-PACKAGE' and/or
;;   `music/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst music-packages
  '(emms))

(defun music/init-emms ()
  (use-package emms
    :defer t
    :commands emms 
    :config
    (progn
      (package-install 'emms)
      (require 'emms-setup)
      (require 'emms-browser)
      (emms-standard)

      (defvar *fixed-emms-change-amount* 10)

      (setq emms-score-file "~/.emacs.d/emms/scores"
            emms-stream-bookmarks-file "~/.emacs.d/emms/emms-streams"
            emms-history-file "~/.emacs.d/emms/emms-history"
            emms-cache-file "~/.emacs.d/emms/emms-cache"
            emms-source-file-default-directory "~/Music")

      (setq emms-score-enabled-p t
            emms-browser-default-browse-type 'info-album
            emms-stream-default-action "play")

      (defun spacemacs-track-description-function (track)
        (let* ((empty "...")
               (name (emms-track-name track))
               (type (emms-track-type track))
               (play-count (or (emms-track-get track 'play-count) 0))
               (last-played (or (emms-track-get track 'last-played) '(0 0 0)))
               (artist (or (emms-track-get track 'info-artist) empty))
               (year (emms-track-get track 'info-year))
               (playing-time (or (emms-track-get track 'info-playing-time) 0))
               (min (/ playing-time 60))
               (sec (% playing-time 60))
               (album (or (emms-track-get track 'info-album) empty))
               (tracknumber (emms-track-get track 'info-tracknumber))
               (short-name (file-name-sans-extension
                            (file-name-nondirectory name)))
               (title (or (emms-track-get track 'info-title) short-name))
               (rating (emms-score-get-score name))
               (rate-char ?\u2665))
          (format "%2s. %20s - %20s - %20s |%2d%s"
                  tracknumber
                  (substring title
                             0
                             (min 20 (length title)))
                  (substring album
                             0
                             (min 20 (length album)))
                  (substring artist
                             0
                             (min 20 (length artist)))
                  play-count
                  (make-string rating rate-char))))

      (setq emms-track-description-function
            'spacemacs-track-description-function)

      (require 'emms-mode-line)
      (require 'emms-playing-time)
      (defun my-mode-line-function ()
        (let* ((track (emms-playlist-current-selected-track))
               (empty "...")
               (name (emms-track-name track))
               (short-name (file-name-sans-extension
                            (file-name-nondirectory name)))
               (title (or (emms-track-get track 'info-title) short-name))
               (artist (emms-track-get track 'info-artist))
               (playing-time (or (emms-track-get track 'info-playing-time) 0))

               (line-string ""))
          ;; (if (not (null artist))
          ;;     (setq line-string (concat line-string (format "%s - " artist))))
          (setq line-string (concat line-string (format "%s"
                                                        (substring
                                                         title
                                                         0
                                                         (min 20 (length title))))))
          (format emms-mode-line-format line-string)))

      (setq emms-mode-line-mode-line-function 'my-mode-line-function)

      (emms-mode-line-enable)
      (emms-playing-time 1)

      (require 'emms-score)
      (emms-score-enable)

      (setq emms-volume-change-amount 5)
      (defun emms-volume-change-by-fixed-amount (lower-or-raise-func)
        (interactive)
        (let ((old-volume-amount emms-volume-change-amount))
          (setq emms-volume-change-amount *fixed-emms-change-amount*)
          (funcall lower-or-raise-func)
          (setq emms-volume-change-amount old-volume-amount)))


;;; mpd setup
      (require 'emms-player-mpd)
      (add-to-list 'emms-info-functions 'emms-info-mpd)
      (add-to-list 'emms-player-list 'emms-player-mpd)
      (setq emms-player-mpd-music-directory emms-source-file-default-directory)

      ;;; Setup keys:
      (spacemacs/set-leader-keys "amo" 'emms)
      (spacemacs/set-leader-keys "amS" 'emms-start)
      (spacemacs/set-leader-keys "ams" 'emms-stop)
      (spacemacs/set-leader-keys "amP" 'emms-pause)
      (spacemacs/set-leader-keys "amp" 'emms-previous)
      (spacemacs/set-leader-keys "amn" 'emms-next)
      (spacemacs/set-leader-keys "am+" 'emms-volume-raise)
      (spacemacs/set-leader-keys "am-" 'emms-volume-raise)
      (spacemacs/set-leader-keys "am*"
        (lambda ()
          (interactive)
          (emms-volume-change-by-fixed-amount 'emms-volume-raise)))
      (spacemacs/set-leader-keys "am_"
        (lambda ()
          (interactive)
          (emms-volume-change-by-fixed-amount 'emms-volume-lower)))
      (spacemacs/set-leader-keys "aml" 'emms-add-playlist)
      (spacemacs/set-leader-keys "amf" 'emms-add-file)
      (spacemacs/set-leader-keys "amF" 'emms-add-find)
      (spacemacs/set-leader-keys "am<" 'emms-seek-backward)
      (spacemacs/set-leader-keys "am>" 'emms-seek-forward)
      (spacemacs/set-leader-keys "amh" 'emms-shuffle)
      (spacemacs/set-leader-keys "amc" 'emms-playlist-clear))))

(defun music/init-soundklaus ()
  (use-package soundklaus
    :commands soundklaus-tracks))


;;; packages.el ends here
