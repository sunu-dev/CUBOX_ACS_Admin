package aero.cubox.door.service.impl;

import egovframework.rte.psl.dataaccess.EgovAbstractMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository("doorDAO")
public class DoorDAO extends EgovAbstractMapper {

	private static final String sqlNameSpace = "door.";


	public List<Map> getDoorList(Map<String, Object> paramMap) {
		return selectList(sqlNameSpace+"selectDoorList", paramMap);
	}

	public Map getDoorDetail(Map<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectDoorDetail", paramMap);
	}


	public int insertDoor(Map<String, Object> paramMap) {
		insert(sqlNameSpace+"insertDoor", paramMap);
        return 0;
    }

	public void updateDoor(Map<String, Object> paramMap) {
		update(sqlNameSpace+"updateDoor", paramMap);
	}
	public void updateDoorBySchedule(Map<String, Object> paramMap) {
		update(sqlNameSpace+"updateDoorBySchedule", paramMap);
	}

	public void updateDoorByScheduleInit(Map<String, Object> paramMap) {
		update(sqlNameSpace+"updateDoorByScheduleInit", paramMap);
	}

	public void deleteDoor(Map<String, Object> paramMap) {
		delete(sqlNameSpace+"deleteDoor", paramMap);
	}
	public void deleteDoorAll() {
		delete(sqlNameSpace+"deleteDoorAll");
	}


	public List<HashMap> getAreaList(Map<String, Object> paramMap) {
		return selectList(sqlNameSpace+"selectAreaList", paramMap);
	}

	public List<HashMap> getBuildingList(Map<String, Object> paramMap) {
		return selectList(sqlNameSpace+"selectBuildingList", paramMap);
	}

	public List<HashMap> getWorkplaceList(Map<String, Object> paramMap) {
		return selectList(sqlNameSpace+"selectWorkplaceList", paramMap);
	}

	public List<HashMap> getFloorList(Map<String, Object> paramMap) {
		return selectList(sqlNameSpace+"selectFloorList", paramMap);
	}


	public HashMap getTerminalDetail(Map<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectTerminalDetail", paramMap);
	}


	public List<HashMap> getTerminalList(Map<String, Object> paramMap) {
		return selectList(sqlNameSpace+"selectTerminalList", paramMap);
	}

    public void updateDoorIdForTerminal(Map<String, Object> paramMap) {
		update(sqlNameSpace+"updateDoorIdForTerminal", paramMap);
	}

	public void deleteDoorIdForTerminal(Map<String, Object> paramMap) {
		delete(sqlNameSpace+"deleteDoorIdForTerminal", paramMap);
	}

	public void updateDoorIdForAuthDoor(Map<String, Object> paramMap) {
		update(sqlNameSpace+"updateDoorIdForTerminal", paramMap);
	}

	public void insertDoorIdForAuthDoor(Map<String, Object> paramMap) {
		insert(sqlNameSpace+"insertDoorIdForAuthDoor", paramMap);
	}

	public void deleteDoorIdForAuthDoor(Map<String, Object> paramMap) {
		delete(sqlNameSpace+"deleteDoorIdForAuthDoor", paramMap);
	}

	public void insertBuilding(HashMap paramMap) {
		insert(sqlNameSpace+"insertBuilding", paramMap);
	}
	public void updateBuilding(Map<String, Object> paramMap) {
		update(sqlNameSpace+"updateBuilding", paramMap);
	}

	public void insertArea(HashMap paramMap) {
		insert(sqlNameSpace+"insertArea", paramMap);
	}

	public void updateArea(Map<String, Object> paramMap) {
		update(sqlNameSpace+"updateArea", paramMap);
	}

	public void insertFloor(HashMap paramMap) {
		insert(sqlNameSpace+"insertFloor", paramMap);
	}

	public void updateFloor(Map<String, Object> paramMap) {
		update(sqlNameSpace+"updateFloor", paramMap);
	}


	public void deleteBuildingIdForAuthBuilding(Map<String, Object> paramMap) {
		delete(sqlNameSpace+"deleteBuildingIdForAuthBuilding", paramMap);
	}

	public void insertBuildingIdForAuthBuilding(Map<String, Object> paramMap) {
		insert(sqlNameSpace+"insertBuildingIdForAuthBuilding", paramMap);
	}

	public Map getBuildingDetail(Map<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectBuildingList", paramMap);
	}

	public Map getFloorDetail(Map<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectFloorList", paramMap);
	}

	public Map getAreaDetail(Map<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectAreaList", paramMap);
	}

	public void deleteBuilding(Map<String, Object> paramMap) {
		delete(sqlNameSpace+"deleteBuilding", paramMap);
	}

	public void deleteBuildingAll() {
		delete(sqlNameSpace+"deleteBuildingAll");
	}
	public void deleteArea(Map<String, Object> paramMap) {
		delete(sqlNameSpace+"deleteArea", paramMap);
	}
	public void deleteAreaAll() {
		delete(sqlNameSpace+"deleteAreaAll");
	}

	public void deleteFloor(Map<String, Object> paramMap) {
		delete(sqlNameSpace+"deleteFloor", paramMap);
	}
	public void deleteFloorAll() {
		delete(sqlNameSpace+"deleteFloorAll");
	}

	public int getTerminalUseCnt(HashMap<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectTerminalUseCnt", paramMap);
	}

	public int getBuildingNameVerification(HashMap<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectBuildingNameVerification", paramMap);
	}
	public int getAreaNameVerification(HashMap<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectAreaNameVerification", paramMap);
	}
	public int getFloorNameVerification(HashMap<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectFloorNameVerification", paramMap);
	}
	public int getDoorNameVerification(HashMap<String, Object> paramMap) {
		return selectOne(sqlNameSpace+"selectDoorNameVerification", paramMap);
	}

	public String getTerminalId(String terminalCd) {
		return selectOne(sqlNameSpace+"selectTerminalId", terminalCd);
	}
}
