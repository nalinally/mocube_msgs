cmake_minimum_required(VERSION 3.8)

project(atom_krs_ros_udp_bridge_msg)

find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)

rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/Vector2.msg"
  "msg/IrReceiver.msg"
  "msg/Module.msg"
  "msg/Modules.msg"
)

ament_export_dependencies(rosidl_default_runtime)

ament_package()