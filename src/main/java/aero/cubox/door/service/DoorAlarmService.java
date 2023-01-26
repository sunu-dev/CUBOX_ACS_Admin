package aero.cubox.door.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface DoorAlarmService {

    //출입문 알람 그룹
    List<HashMap> getDoorAlarmGrpList(Map<String, Object> commandMap);
    int getDoorAlarmGrpListCount(HashMap<String, Object> paramMap);
    HashMap getDoorAlarmGrpDetail( int id );
    String addDoorAlarmGrp(Map<String, Object> commandMap);
    void updateDoorAlarmGrp(Map<String, Object> commandMap);

    void deleteDoorAlarmGrp(int commandMap);

    int getDoorAlarmGroupNameVerification(HashMap<String, Object> param);

    List<HashMap> getDoorAlarmTypeList();

    List<HashMap> getAlarmUseTypeList();
}
