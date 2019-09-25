\c deepface_v5;

update func_role set func_auth_flag = '{"home":"rw","monitor":"rw","search-image":"rw","search-cap":"rw","search-repo":"rw","search-illegalsearch":"rw","search-eventsearch":"rw","face-compare":"rw","face-repocollision":"rw","face-trajectory":"rw","dossier":"rw","stat":"rw","rule":"rw","repo":"rw","event":"rw","whiteevent":"rw","task":"rw","sensor":"rw","sensorgeo":"rw","org":"rw","role":"rw","user":"rw","system-setting":"rw","record":"rw","system-operation":"rw","frequencyanalyze":"rw"}' where func_role_type = 3;


create or replace FUNCTION update_func_role_by_org() RETURNS TRIGGER AS $update_func_role_by_org$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO func_role(ts, func_role_id, func_role_name, org_id, func_role_type, func_auth_flag, comment) VALUES(New.ts, uuid_generate_v4(), NEW.org_name || '默认操作员', NEW.org_id, 1, '{"home":"rw","monitor":"rw","search-image":"rw","search-cap":"rw","search-repo":"rw","face-compare":"rw","face-repocollision":"rw","personfile":"rw","stat":"rw"}', '');
    INSERT INTO func_role(ts, func_role_id, func_role_name, org_id, func_role_type, func_auth_flag, comment) VALUES(New.ts, uuid_generate_v4(), NEW.org_name || '默认管理员', NEW.org_id, 3, '{"home":"rw","monitor":"rw","search-image":"rw","search-cap":"rw","search-repo":"rw","search-illegalsearch":"rw","search-eventsearch":"rw","face-compare":"rw","face-repocollision":"rw","face-trajectory":"rw","dossier":"rw","stat":"rw","rule":"rw","repo":"rw","event":"rw","whiteevent":"rw","task":"rw","sensor":"rw","sensorgeo":"rw","org":"rw","role":"rw","user":"rw","system-setting":"rw","record":"rw","system-operation":"rw","frequencyanalyze":"rw"}', '');
  ELSEIF (TG_OP = 'UPDATE') THEN
    UPDATE func_role SET func_role_name = NEW.org_name || '默认操作员' WHERE org_id = NEW.org_id AND func_role.func_role_type = 1;
    UPDATE func_role SET func_role_name = NEW.org_name || '默认管理员' WHERE org_id = NEW.org_id AND func_role.func_role_type = 3;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$update_func_role_by_org$ LANGUAGE 'plpgsql';

drop trigger update_func_role_by_org ON org_structure;

create TRIGGER update_func_role_by_org AFTER insert OR update OR delete ON org_structure
    FOR EACH ROW EXECUTE PROCEDURE update_func_role_by_org();


alter table pedestrian_capture add column has_face boolean not null default false;
alter table nonmotor_capture add column has_face boolean not null default false;
alter table vehicle_capture add column has_face boolean not null default false;
alter table vehicle_capture_index add column has_face boolean not null default false;

alter table vehicle_capture add column symbols_desc varchar (1024) not null default '';
alter table vehicle_capture_index add column symbols_desc varchar (1024) not null default '';

alter table vehicle_capture_index add column symbols json not null default '{}';





    --给tasks表添加占用路数字段
alter table tasks add column channel integer not null default 0;

-- 国标平台同步
drop TABLE
IF
	EXISTS "platform_sync_gb";
create table "platform_sync_gb" (
"uts" timestamp default now() not null,
"ts" bigint not null default 0,
"device_id" varchar ( 1024 ) primary key not null,
"sensor_id" varchar ( 1024 ) not null,
"online" smallint not null default 0,
"parent_id" varchar ( 1024 ) not null default '',
"name" varchar ( 1024 ) not null,
"longitude" double precision default '-200',
"latitude" double precision default '-200',
"manufacturer" varchar ( 1024 ) not null default '',
"model" varchar ( 1024 ) not null default '',
"owner" varchar ( 1024 ) not null default '',
"civil_code" varchar ( 1024 ) not null default '',
"address" varchar ( 1024 ) not null default '',
"ip_address" varchar ( 1024 ) not null default '',
"port" int not null default 0,
"parental" int not null default 0,
"secrecy" int not null default 0,
--1:未分配,2:已分配
"is_distribute" int not null default 1
);
create TRIGGER update_platform_sync_gb_changetimestamp BEFORE update
  ON platform_sync_gb FOR EACH ROW EXECUTE PROCEDURE
  update_changetimestamp_column();
-- 设备表添加外部平台状态
alter TABLE sensors ADD COLUMN outer_platform_status INTEGER NOT NULL DEFAULT 0;

--车辆表添加reid索引
create index vehicle_capture_vehicle_reid_ts_idx on vehicle_capture(vehicle_reid,ts desc);

-- Athena任务表
drop TABLE
IF
	EXISTS "athena_task";
create table "athena_task" (
"uts" timestamp default now() not null,
"ts" bigint not null default 0,
"task_id" varchar ( 1024 ) primary key not null,
"name" varchar ( 1024 ) not null default '',
"user_id" varchar ( 1024 ) not null,
"org_id" varchar ( 1024 ) not null,
"type" smallint not null default 0,
"inner_type" smallint not null default 0,
"start_ts" bigint not null default 0, -- 起始时间
"end_ts" bigint not null default 0 -- 结束时间
);
create TRIGGER update_athena_task_changetimestamp BEFORE update
  ON athena_task FOR EACH ROW EXECUTE PROCEDURE
  update_changetimestamp_column();
create index athena_task_user_id_idx on athena_task(user_id);
create index athena_task_org_id_idx on athena_task(org_id);
create index athena_task_type_idx on athena_task(type);
create index athena_task_inner_type_idx on athena_task(inner_type);

-- 车辆频次分析任务表
drop TABLE
IF
	EXISTS "vehicle_frequency_task";
create table "vehicle_frequency_task" (
"uts" timestamp default now() not null,
"ts" bigint not null default 0,
"task_id" varchar ( 1024 ) primary key not null default '',
"sensor_ids" text not null default '', -- 很多设备按","拼接, 最多 500 个, 可能会很长
"times_threshold" bigint not null default 0, -- 频次阈值
"plate" varchar ( 1024 ) not null default '' -- 车牌号
);
create TRIGGER update_vehicle_frequency_task_changetimestamp BEFORE update
  ON vehicle_frequency_task FOR EACH ROW EXECUTE PROCEDURE
  update_changetimestamp_column();


  -- Athena写 loki读 车辆频次分析-设备的频次结果 概述表
drop table
IF
	EXISTS "vehicle_frequency_summary";
create table "vehicle_frequency_summary" (
"uts" timestamp default now() not null,
"ts" bigint not null default 0,
"task_id" varchar ( 1024 ) not null,
"sensor_id" varchar ( 1024 ) not null,
"sensor_name" varchar ( 1024 ) not null default '',
"count" bigint not null default 0 -- 某 task 下, 某 sensor 分析出了 count 个结果(每个结果是一个 vid)
);
create unique index vehicle_frequency_summary_task_sensor_idx on vehicle_frequency_summary (task_id, sensor_id);
create trigger update_vehicle_frequency_summary_changetimestamp before update
  on vehicle_frequency_summary for each row EXECUTE procedure
  update_changetimestamp_column();

-- Athena写 loki读 车辆频次分析-设备的频次结果 详情表
-- 由 task_id, sensor_id, sensor_name + vehicle_index表的全部字段组成
drop TABLE
IF
	EXISTS "vehicle_frequency_detail";
create table "vehicle_frequency_detail" (
    "uts" timestamp default now() not null,
    "ts" bigint not null default 0,
    "task_id" varchar ( 1024 ) not null,
    "sensor_name" varchar ( 1024 ) not null default '',
    "max_ts_tag" int2 not null default 0, -- tag标记:  该 reid 是否为同一 vid 下最大的 ts, 默认为 0, 置位 1 时生效
    "reid_count" bigint not null default 0, -- 聚合count: 同一 vid 下, reid 的数量, 在max_ts_tag==1 时才会有值
--from vehicle_capture_index
	"vehicle_id" varchar ( 36 ) not null default '',
	"vehicle_reid" varchar ( 36 ) not null default '',
	"vehicle_vid" varchar ( 36 ) not null default '',
	"repo_id" varchar ( 36 ) not null default '',
	"sensor_id" varchar ( 36 ) not null default '',
	"enter_time_millisecond" int8 not null default 0,
	"leave_time_millisecond" int8 not null default 0,
--base
	"confidence" float4 not null default 0,
	"speed" int2 not null default 0,
	"direction" int2 not null default 0,
	"face_id" varchar ( 256 ) not null default '',
	"image_id" varchar ( 36 ) not null default '',
	"image_uri" text not null default '',
	"cutboard_image_uri" text not null default '',
    "cutboard_x" int4 not null default 0,
    "cutboard_y" int4 not null default 0,
    "cutboard_width" int4 not null default 0,
    "cutboard_height" int4 not null default 0,
    "cutboard_res_width" int4 not null default 0,
    "cutboard_res_height" int4 not null default 0,
--advance
	"brand_id" int2 not null default 0,
	"sub_brand_id" int2 not null default 0,
	"model_year_id" int2 not null default 0,
	"type_id" int2 not null default 0,
	"side" int2 not null default 0,
	"color_id" int2 not null default 0,
	"plate_text" varchar ( 32 ) not null default '',
	"plate_type_id" int2 not null default 0,
	"plate_color_id" int2 not null default 0,
	"symbol_int" int8 not null default 0,
	"symbol_str" varchar ( 15 ) not null default '',
	"illegal_int" int8 not null default 0,
	"illegal_str" varchar ( 15 ) not null default '',
	"coillegal_int" int8 not null default 0,
	"coillegal_str" varchar ( 15 ) not null default '',
	"special_int" int8 not null default 0,
	"special_str" varchar ( 15 ) not null default '',
	"driver_on_the_phone" bool not null default false,
	"driver_without_belt" bool not null default false,
	"codriver_without_belt" bool not null default false,
	"content" text not null default '',
	"lane" varchar ( 255 ) not null default '',
	"has_face" boolean not null default false
);
create index vehicle_frequency_detail_task_idx on vehicle_frequency_detail (task_id); -- 用于 delete task
create index vehicle_frequency_detail_tag_sensor_task_ts_idx on vehicle_frequency_detail (max_ts_tag, sensor_id, task_id, ts desc); -- 用于 vid list
create index vehicle_frequency_detail_vid_sensor_task_ts_idx on vehicle_frequency_detail (vehicle_vid, sensor_id, task_id, ts desc); -- 用于 reid list
create trigger update_vehicle_frequency_detail_changetimestamp before update
  on vehicle_frequency_detail for each row EXECUTE procedure
  update_changetimestamp_column();

-- 人员频次分析任务表
drop TABLE
IF
	EXISTS "person_frequency_task";
create table "person_frequency_task" (
"uts" timestamp default now() not null,
"ts" bigint not null default 0,
"task_id" varchar ( 1024 ) primary key not null default '',
"sensor_ids" text not null default '', -- 很多设备按","拼接, 最多 500 个, 可能会很长
"times_threshold" bigint not null default 0, -- 频次阈值
"id_no" varchar ( 1024 ) not null default '' -- 身份证号
);
create TRIGGER update_person_frequency_task_changetimestamp BEFORE update
  ON person_frequency_task FOR EACH ROW EXECUTE PROCEDURE
  update_changetimestamp_column();

-- Athena写 loki读 人员频次分析-设备的频次结果 概述表
drop table
IF
	EXISTS "person_frequency_summary";
create table "person_frequency_summary" (
"uts" timestamp default now() not null,
"ts" bigint not null default 0,
"task_id" varchar ( 1024 ) not null,
"sensor_id" varchar ( 1024 ) not null,
"sensor_name" varchar ( 1024 ) not null default '',
"count" bigint not null default 0 -- 某 task 下, 某 sensor 分析出了 count 个结果(每个结果是一个 vid)
);
create unique index person_frequency_summary_task_sensor_idx on person_frequency_summary (task_id, sensor_id);
create trigger update_person_frequency_summary_changetimestamp before update
  on person_frequency_summary for each row EXECUTE procedure
  update_changetimestamp_column();

-- Athena写 loki读 人员频次分析-设备的频次结果 详情表
-- 由 task_id, sensor_id, sensor_name + faces_index表的全部字段组成
drop TABLE
IF
	EXISTS "person_frequency_detail";
create table "person_frequency_detail" (
    "uts" timestamp default now() not null,
    "ts" bigint not null default 0,
    "task_id" varchar ( 1024 ) not null,
    "sensor_id" varchar(1024) not null,
    "sensor_name" varchar ( 1024 ) not null default '',
    "max_ts_tag" int2 not null default 0, -- tag标记:  该 reid 是否为同一 vid 下最大的 ts, 默认为 0, 置位 1 时生效
    "reid_count" bigint not null default 0, -- 聚合count: 同一 vid 下, reid 的数量, 在max_ts_tag==1 时才会有值
--from faces_index
    face_id varchar(1024)  not null default '',
    face_reid varchar(1024) not null default '',
    face_vid varchar(1024) not null default '',
    feature text default '',
    confidence real not null default 0,

    gender_id smallint not null default 0,
    gender_confidence real not null  default 0,
    age_id smallint not null default 0,
    age_confidence real not null default 0,
    nation_id smallint not null default 0,
    nation_confidence real not null default 0,
    glass_id smallint default 0,
    glass_confidence real not null default 0,
    mask_id smallint not null default 0,
    mask_confidence real not null default 0,
    hat_id smallint not null default 0,
    hat_confidence real not null default 0,
    halmet_id smallint not null default 0,
    halmet_confidence real not null default 0,
    image_type smallint not null default 0,
    image_uri varchar(256) default '' ,
    thumbnail_image_uri varchar(256) default '',
    cutboard_image_uri varchar(256) default '',
    cutboard_x int default 0,
    cutboard_y int default 0,
    cutboard_width int default 0,
    cutboard_height int default 0,
    cutboard_res_width int default 0,
    cutboard_res_height int default 0,
    is_warned smallint default 0,

    status smallint not null default 1
);
create index person_frequency_detail_task_idx on person_frequency_detail (task_id); -- 用于 delete task
create index person_frequency_detail_tag_sensor_task_ts_idx on person_frequency_detail (max_ts_tag, sensor_id, task_id, ts desc); -- 用于 vid list
create index person_frequency_detail_vid_sensor_task_ts_idx on person_frequency_detail (face_vid, sensor_id, task_id, ts desc); -- 用于 reid list
create trigger update_person_frequency_detail_changetimestamp before update
  on person_frequency_detail for each row EXECUTE procedure
  update_changetimestamp_column();

--车辆档案表
create table vehicle_file (
  vid varchar(1024) primary key not null,
  ts bigint not null default 0,
  uts timestamp default now() not null,
  comment text default '',
  image_url text not null default '',
  plate_text varchar ( 10 ) not null default '',
  plate_color_id int2 not null default 0,
  color_id int2 not null default 0,
  brand_id int2 not null default 0,
  sub_brand_id int2 not null default 0,
  model_year_id int2 not null default 0,
  type_id int2 not null default 0,
  status smallint not null default 1,
  tag smallint not null default 0
);

create trigger update_vehicle_file_changetimestamp before update on
vehicle_file for each row execute procedure update_changetimestamp_column();

create index vehicle_vid_ts on vehicle_capture_index (vehicle_vid, ts);

-- 行人、车辆表has_face索引
create index vehicle_has_face_idx on vehicle_capture (has_face);
create index vehicle_index_has_face_idx on vehicle_capture_index (has_face);
create index pedestrian_has_face_idx on pedestrian_capture (has_face);
create index nonmotor_has_face_idx on nonmotor_capture (has_face);

DROP TABLE
IF
	EXISTS "vehicle_brand_dict";
CREATE TABLE "vehicle_brand_dict" (
"brand_id" SMALLINT NOT NULL,
"sub_brand_id" SMALLINT NOT NULL,
"year_id" SMALLINT NOT NULL,
"desc" VARCHAR ( 1024 ) NOT NULL
);

