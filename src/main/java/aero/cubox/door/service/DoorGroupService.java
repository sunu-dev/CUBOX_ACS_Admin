package aero.cubox.door.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface DoorGroupService {


    //출입문 그룹
    List<HashMap> getSchDoorGroupList(Map<String, Object> commandMap);

    int getDoorGroupListCount(Map<String, Object> commandMap);

    HashMap getDoorGroupDetail(int id);

    String addDoorGroup(Map<String, Object> commandMap);
    void addDoorInDoorGroup(Map<String, Object> commandMap);

    void updateDoorGroup(Map<String, Object> commandMap);

    void deleteDoorGroup(int id);


    int getDoorGroupNameVerification(HashMap<String, Object> param);

}
