#!/usr/bin/env roseus
(ros::roseus "grasp_result_check")

(ros::load-ros-manifest "aginika_baxter_grasp_training")
(setq *right-grasp-state* nil)
(setq *left-grasp-state* nil)

(defun grasp-checK(req)
  (let ((m (send req :response)))
    (send m :right_grasp *right-grasp-state*)
    (send m :left_grasp *left-grasp-state*)
    m
    )
  )

(defun right-cb(msg)
  (if (> (send msg :force ) 0)
      (setq *right-grasp-state* t)
    (setq *right-grasp-state* nil)
    )
  )

(defun left-cb(msg)
  (if (> (send msg :force ) 0)
      (setq *left-grasp-state* t)
    (setq *left-grasp-state* nil)
    )
  )

(ros::advertise-service "grasp_state" aginika_baxter_grasp_training::GraspCheck #'grasp-check)
(ros::subscribe "/robot/end_effector/right_gripper/state" baxter_core_msgs::EndEffectorState #'right-cb)
(ros::subscribe "/robot/end_effector/left_gripper/state" baxter_core_msgs::EndEffectorState #'left-cb)

(while (ros::ok)
 (ros::spin-once)
 (ros::sleep)
 )
