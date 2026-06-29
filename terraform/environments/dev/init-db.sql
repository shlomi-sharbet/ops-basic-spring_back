CREATE DATABASE IF NOT EXISTS students_stage_ecs;
CREATE USER IF NOT EXISTS 'students_staging_ecs'@'%' IDENTIFIED BY 'students_staging_ecs';
GRANT all PRIVILEGES on students_stage_ecs.* to 'students_staging_ecs'@'%';
