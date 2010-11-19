;; source files
(set @nu_files		(filelist "^nu/.*nu$"))
(set @m_files		(filelist "^src/.*.m$"))

(ifDarwin
          (then (set @arch '("i386")))) ;; optionally add "ppc" or "ppc64" to the list

(if (isSnowLeopard)
     (then (set @arch (append @arch '("x86_64")))))

;(set @cflags 	"-fobjc-gc -g -DDARWIN -Iobjc")
;(set @ldflags  "-fobjc-gc -framework Foundation -framework AppKit -framework Nu")

(set @cflags 	"-g -std=c99 -DDARWIN -Iobjc")
(set @ldflags  "-framework Foundation -framework AppKit -framework Nu")

;; framework description
(set @framework					"Nutron")
(set @framework_identifier		"nu.programming.nutron")
(set @framework_creator_code	"????")

(set @public_headers (filelist "^src/.*\.h$"))

(compilation-tasks)
(framework-tasks)

(task "default" => "framework")

(task "clobber" => "clean" is
      (SH "rm -rf #{@framework_dir}"))

(task "default" => "framework")

; (task "doc" is (SH "nudoc"))

(task "install" => "framework" is
      (SH "sudo rm -rf /Library/Frameworks/#{@framework}.framework")
      (SH "ditto #{@framework}.framework /Library/Frameworks/#{@framework}.framework"))

