package aero.cubox.door.service;


import org.apache.poi.ss.usermodel.Sheet;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface DoorService {

    //출입문
    List<Map> getDoorList(Map<String, Object> commandMap);
    Map getDoorDetail(Map<String, Object> commandMap);
    String addDoor(Map<String, Object> commandMap);
    void updateDoor(Map<String, Object> commandMap);
    void deleteDoor(Map<String, Object> commandMap);
    void deleteDoorAll();

    //단말기
    List<HashMap> getTerminalList(Map<String, Object> commandMap);

    //workpalce
    List<HashMap> getWorkplaceList(Map<String, Object> commandMap);

    //building
    List<HashMap> getBuildingList(Map<String, Object> commandMap);
    Map getBuildingDetail(Map<String, Object> commandMap);
    String addBuilding(HashMap param);
    void updateBuilding(Map<String, Object> commandMap);
    void deleteBuilding(Map<String, Object> commandMap);
    void deleteBuildingAll();
    String getBuildingCd(String buildingId);

    //area
    List<HashMap> getAreaList(Map<String, Object> commandMap);
    Map getAreaDetail(HashMap<String, Object> param);
    String addArea(HashMap param);
    void updateArea(Map<String, Object> commandMap);
    void deleteArea(Map<String, Object> commandMap);
    void deleteAreaAll();

    //floor
    List<HashMap> getFloorList(Map<String, Object> commandMap);
    Map getFloorDetail(Map<String, Object> commandMap);
    String addFloor(HashMap param);
    void updateFloor(Map<String, Object> commandMap);
    void deleteFloor(Map<String, Object> commandMap);
    void deleteFloorAll();
    String getFloorCd(String floorId);


    int getTerminalUseCnt(HashMap<String, Object> param);

    int getBuildingNameVerification(HashMap<String, Object> param);
    int getAreaNameVerification(HashMap<String, Object> param);
    int getFloorNameVerification(HashMap<String, Object> param);
    int getDoorNameVerification(HashMap<String, Object> param);

    // 엑셀
    int addBuildingFloorDoor(Sheet sheet);

}
