# add network category for ZSTAC-6844
DELIMITER $$
CREATE PROCEDURE generateNetworkCategory()
  BEGIN
    DECLARE l3Uuid varchar(32);
    DECLARE l3System tinyint(3) unsigned;
    DECLARE tagUuid varchar(32);
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR SELECT uuid, system FROM zstack.L3NetworkEO;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    read_loop: LOOP
      FETCH cur INTO l3Uuid, l3System;
      IF done THEN
        LEAVE read_loop;
      END IF;
      SET tagUuid = REPLACE(UUID(), '-', '');

      IF l3System = 1
      THEN
        UPDATE zstack.L3NetworkEO SET system = 0 WHERE uuid = l3Uuid;
        INSERT zstack.SystemTagVO(uuid, resourceUuid, resourceType, inherent, type, tag, lastOpDate, createDate)
          value (tagUuid, l3Uuid, 'L3NetworkVO', 0, 'System', 'networkCategory::Public', NOW(), NOW());
      ELSE
        INSERT zstack.SystemTagVO(uuid, resourceUuid, resourceType, inherent, type, tag, lastOpDate, createDate)
          value (tagUuid, l3Uuid, 'L3NetworkVO', 0, 'System', 'networkCategory::Private', NOW(), NOW());
      END IF;

    END LOOP;
    CLOSE cur;
    # work around a bug of mysql : jira.mariadb.org/browse/MDEV-4602
    SELECT CURTIME();
  END $$
DELIMITER ;

CALL generateNetworkCategory();
DROP PROCEDURE IF EXISTS generateNetworkCategory;

update PolicyVO set name='SCHEDULER.JOB.CREATE', data='[{\"name\":\"scheduler.job.create\",\"effect\":\"Allow\",\"actions\":[\"scheduler:APICreateSchedulerJobMsg\"]}]' where name='SCHEDULER.CREATE';
update ResourceVO set resourceName='SCHEDULER.JOB.CREATE' where resourceName='SCHEDULER.CREATE';
update PolicyVO set name='SCHEDULER.JOB.UPDATE', data='[{\"name\":\"scheduler.job.update\",\"effect\":\"Allow\",\"actions\":[\"scheduler:APIUpdateSchedulerJobMsg\"]}]' where name='SCHEDULER.UPDATE';
update ResourceVO set resourceName='SCHEDULER.JOB.UPDATE' where resourceName='SCHEDULER.UPDATE';
update PolicyVO set name='SCHEDULER.JOB.DELETE', data='[{\"name\":\"scheduler.job.delete\",\"effect\":\"Allow\",\"actions\":[\"scheduler:APIDeleteSchedulerJobMsg\"]}]' where name='SCHEDULER.DELETE';
update ResourceVO set resourceName='SCHEDULER.JOB.DELETE' where resourceName='SCHEDULER.DELETE';

DELIMITER $$

DROP FUNCTION IF EXISTS `update_policy` $$

CREATE FUNCTION `update_policy` (
    uuid varchar(32),
    policy_name varchar(255),
    policy_data text
) RETURNS VARCHAR(7) CHARSET utf8

BEGIN
    DECLARE policy_uuid varchar(32);
    DECLARE result_string varchar(7);
    SET result_string = 'success';
    SET policy_uuid = REPLACE(UUID(),'-','');

    INSERT INTO PolicyVO (`uuid`, `name`, `accountUuid`, `data`, `lastOpDate`, `createDate`) VALUES (policy_uuid, name, uuid, data, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());
    INSERT INTO ResourceVO (`uuid`, `resourceName`, `resourceType`) VALUES (policy_uuid, policy_name, policy_data);

    RETURN(result_string);
END$$

DELIMITER  ;

select update_policy(uuid, 'SCHEDULER.TRIGGER.CREATE', '[{\"name\":\"scheduler.trigger.create\",\"effect\":\"Allow\",\"actions\":[\"scheduler:APICreateSchedulerTriggerMsg\"]}]') from AccountVO where type<>'SystemAdmin';
select update_policy(uuid, 'SCHEDULER.TRIGGER.DELETE', '[{\"name\":\"scheduler.trigger.delete\",\"effect\":\"Allow\",\"actions\":[\"scheduler:APIDeleteSchedulerTriggerMsg\"]}]') from AccountVO where type<>'SystemAdmin';
select update_policy(uuid, 'SCHEDULER.TRIGGER.UPDATE', '[{\"name\":\"scheduler.trigger.update\",\"effect\":\"Allow\",\"actions\":[\"scheduler:APIUpdateSchedulerTriggerMsg\"]}]') from AccountVO where type<>'SystemAdmin';
select update_policy(uuid, 'SCHEDULER.ADD', '[{\"name\":\"scheduler.add\",\"effect\":\"Allow\",\"actions\":[\"scheduler:APIAddSchedulerJobToSchedulerTriggerMsg\"]}]') from AccountVO where type<>'SystemAdmin';
select update_policy(uuid, 'SCHEDULER.REMOVE', '[{\"name\":\"scheduler.remove\",\"effect\":\"Allow\",\"actions\":[\"scheduler:APIRemoveSchedulerJobFromSchedulerTriggerMsg\"]}]') from AccountVO where type<>'SystemAdmin';
