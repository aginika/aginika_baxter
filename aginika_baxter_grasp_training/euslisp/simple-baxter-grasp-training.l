#!/usr/bin/env roseus
(ros::roseus "simple_baxter_training")
(load "package://baxtereus/baxter-interface.l")
(load "package://aginika_baxter_grasp_training/euslisp/73b2-baxter-setup.l")

(defun setup()
  (73b2-setup)
  )

(defun main()
  
  )
