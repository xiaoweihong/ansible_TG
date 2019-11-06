su - postgres

psql

\c deepface_v5

select AutoCreatePartitionTable('faces', 'face_id', thisWeekName(), timeZone(weekBegin(0)), timeZone(weekBegin(1)));

select AutoCreatePartitionTable('vehicle_capture_index', 'vehicle_id', thisWeekName(), timeZone(weekBegin(0)), timeZone(weekBegin(1)));

select AutoCreatePartitionTable('vehicle_capture', 'vehicle_id', thisWeekName(), timeZone(weekBegin(0)), timeZone(weekBegin(1)));

select AutoCreatePartitionTable('nonmotor_capture', 'nonmotor_id', thisWeekName(), timeZone(weekBegin(0)), timeZone(weekBegin(1)));

select AutoCreatePartitionTable('pedestrian_capture', 'pedestrian_id', thisWeekName(), timeZone(weekBegin(0)), timeZone(weekBegin(1)));

select AutoCreatePartitionTable('faces_index', 'face_id', thisWeekName(), timeZone(weekBegin(0)), timeZone(weekBegin(1)));

select AutoCreatePartitionTable('white-warn', 'face_id', thisWeekName(), timeZone(weekBegin(0)), timeZone(weekBegin(1)));

select AutoCreatePartitionTable('white-warn_index', 'face_id', thisWeekName(), timeZone(weekBegin(0)), timeZone(weekBegin(1)));

