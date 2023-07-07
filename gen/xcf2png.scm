(define (ends-with? str suffix)
  (let* ((str-len (string-length str))
         (suffix-len (string-length suffix)))
    (and (>= str-len suffix-len)
         (string=? (substring str (- str-len suffix-len)) suffix))))

(define (save-as-png input-path output-path)
  (let* (
          (image (car (gimp-file-load RUN-NONINTERACTIVE input-path input-path)))
          (drawable (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
          (output-path-full 
           (if (ends-with? output-path ".png")
               output-path
               (string-append output-path "/" (car (strbreakup (car (last (strbreakup input-path "/"))) ".")) ".png")
           )
         )
   )
   (file-png-save-defaults RUN-NONINTERACTIVE image drawable output-path-full output-path-full)
   (gimp-image-delete image)
  )
)

(define (main-single-file input-path output-path)
  (save-as-png input-path output-path)
  (gimp-quit 0)
)
