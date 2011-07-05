#.(require :cl-opengl)
#.(require :cl-glut)
 
(defpackage :run-gui
        (:use :cl :gl))
(in-package :run-gui)

(defvar *count* 0)
(defvar *angle* 0)
(defvar *t0* 0)

(cffi:defcallback idle :void ()
  (incf *angle*)
  (when (< 360 *angle*)
    (setf *angle* 0))
  (glut:post-redisplay))

(defun draw-frame ()
  (clear-color 0 0 0 1)
  (clear :color-buffer :depth-buffer)
  (push-matrix)
  (rotate *angle* 0 0 1)
  (with-primitive :lines
    (vertex 0 0) (vertex 10 10))
  (pop-matrix)

  ;; Calculating frame rate
  (incf *count*)
  (let ((time (get-internal-real-time)))
    (when (= *t0* 0)
      (setq *t0* time))
    (when (>= (- time *t0*) (* 5 internal-time-units-per-second))
      (let* ((seconds (/ (- time *t0*) internal-time-units-per-second))
             (fps (/ *count* seconds)))
        (format *terminal-io* "~D frames in ~3,1F seconds = ~6,3F FPS~%"
                *count* seconds fps))
      (setq *t0* time)
      (setq *count* 0))))

(cffi:defcallback draw :void ()
  (draw-frame)
  (glut:swap-buffers))

(cffi:defcallback key :void ((key :uchar) (x :int) (y :int))
  (declare (ignore x y))
  (case (code-char key)
    (#\Esc (glut:leave-main-loop)))
  (glut:post-redisplay))

(defun run ()
  (glut:init)
  (glut:init-display-mode :double :rgb :depth)
  (glut:create-window "raaaw")
  (glut:idle-func (cffi:callback idle))
  (glut:display-func (cffi:callback draw))
  (glut:keyboard-func (cffi:callback key))
  (glut:main-loop))

#+nil
(run)