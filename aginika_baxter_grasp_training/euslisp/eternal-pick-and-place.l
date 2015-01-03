#!/usr/bin/env roseus
(ros::roseus "simple_baxter_training")
(load "package://baxtereus/baxter-interface.l")
(ros::load-ros-manifest "jsk_pcl_ros")
(ros::load-ros-manifest "jsk_interactive_marker")

(setq box-num 0)
(setq box nil)

(defvar *max-y* 0)
(defvar *min-y* -300)
(defvar *max-x* 500)
(defvar *min-x* 0)

(defun box-cb(msg)
  (when (> (length (send msg :boxes)) 0 )
    (let (request-index
	  (req (instance jsk_interactive_marker::IndexRequestRequest :init)))
      (setq box-num (length (send msg :boxes)))
      (when box-num
	;;Send service request
	(setq request-index (random box-num))
	(setq box (elt (send msg :boxes) request-index))
	
	(send req :index :data request-index)
	(send req :index :header (send box :header))
	(ros::service-call "/bounding_box_marker/request_id" req)
	)
      )
    )
  )

(defun get-put-destination(handle-pose)
  (let ((msg (instance geometry_msgs::PoseStamped :init)))
    (send msg :header :stamp (ros::time-now))
    (send msg :header :frame_id (send box :header :frame_id))
    (send msg :pose handle-pose)
    ;; (send msg :pose :position :x )
    ;; (send msg :pose :position :y )
    ;; (send msg :pose :position :z )
    ;; (send msg :pose :orientation :x 0)
    ;; (send msg :pose :orientation :y 0)
    ;; (send msg :pose :orientation :z 0)
    ;; (send msg :pose :orientation :w 0)
    msg
    )
  )

(defun random-region(min max)
  (+ min (random (- max min)))
  )

(defun handle-cb(msg)
  (let ((pub-msg (instance jsk_pcl_ros::BoundingBoxMovement :init)) dest-pose dest-coords)
    ;; (ros::ros-info "handle ~A ~A ~A ~A" (send msg :header :frame_id) (send msg :pose :position :x) (send msg :pose :position :y) (send msg :pose :position :z))

    (setq handle-pose (ros::coords->tf-pose (send (ros::tf-pose->coords (send box :pose)) :transformation  (ros::tf-pose->coords (send msg :pose)))))
    (send pub-msg :handle_pose handle-pose)
    (send pub-msg :box box)
    (setq dest-coords (ros::tf-pose->coords  (send box :pose)))
    (ros::ros-info "dest-coords ~A " dest-coords)

    (send dest-coords :locate (float-vector
			       (random-region *min-x* *max-x*)
;;			       (elt (send dest-coords :pos) 0)
			       (random-region *min-y* *max-y*)
			       (elt (send dest-coords :pos) 2)) :world)
;;    (send dest-coords :rotate (random-region (deg2rad -60) (deg2rad 60) ) :z)
    (ros::ros-info "dest-coords AFTER ~A " dest-coords)
    (setq dest-pose (ros::coords->tf-pose dest-coords))
    (send pub-msg :destination (get-put-destination dest-pose))
    (ros::publish "/interactive_point_cloud/box_movement" pub-msg)
    )
  )

(ros::subscribe "/cluster_decomposer_final/boxes"   jsk_pcl_ros::BoundingBoxArray #'box-cb)
(ros::subscribe "/handle_estimator/output_best_preapproach"   geometry_msgs::PoseStamped #'handle-cb)
(ros::advertise "/interactive_point_cloud/box_movement" jsk_pcl_ros::BoundingBoxMovement)
(ros::spin)

