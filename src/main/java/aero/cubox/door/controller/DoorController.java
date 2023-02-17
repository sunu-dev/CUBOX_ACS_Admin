package aero.cubox.door.controller;

import aero.cubox.auth.service.AuthService;
import aero.cubox.cmmn.service.CommonService;
import aero.cubox.core.vo.AuthVO;
import aero.cubox.door.service.DoorAlarmService;
import aero.cubox.door.service.DoorGroupService;
import aero.cubox.door.service.DoorScheduleService;
import aero.cubox.door.service.DoorService;
import aero.cubox.terminal.service.TerminalService;
import aero.cubox.util.CommonUtils;
import aero.cubox.util.StringUtil;
import org.apache.cxf.common.i18n.UncheckedException;
import org.apache.poi.ss.usermodel.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.UncheckedIOException;
import java.util.*;

/**
 * 출입문관리
 */
@Controller
@RequestMapping(value = "/door/")
public class DoorController {

    @Resource(name = "commonUtils")
    private CommonUtils commonUtils;

    @Resource(name = "commonService")
    private CommonService commonService;

    @Resource(name = "doorService")
    private DoorService doorService;

    @Resource(name = "doorGroupService")
    private DoorGroupService doorGroupService;

    @Resource(name = "doorScheduleService")
    private DoorScheduleService doorScheduleService;

    @Resource(name = "doorAlarmService")
    private DoorAlarmService doorAlarmService;

    @Resource(name = "terminalService")
    private TerminalService terminalService;

    @Resource(name = "authService")
    private AuthService authService;


    // 오류코드 정의
    final String EB01 = "EB01";     // 빌딩 명 없음
    final String EB02 = "EB02";     // 빌딩 코드 없음
    final String EF01 = "EF01";     // 층 명 없음
    final String EF02 = "EF02";     // 층 코드 없음
    final String ED01 = "ED01";     // 출입문 명 없음
    final String ED02 = "ED02";     // 출입문 코드 없음
    final String ED03 = "ED03";     // 출입문 코드 중복



    private static final Logger LOGGER = LoggerFactory.getLogger(DoorController.class);

    /**
     * 출입문관리 - view
     *
     * @param model
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/management.do", method = RequestMethod.GET)
    public String doorManagementDetail(ModelMap model) throws Exception {
        //todo 세션처리

        HashMap paramMap = new HashMap();
        List<Map> workplaceList = doorService.getWorkplaceList(paramMap);                       //사업장 목록
        List<Map> buildingList = doorService.getBuildingList(paramMap);                         //빌딩 목록
       // List<Map> areaList = doorService.getAreaList(paramMap);                               //지역 목록
        List<HashMap> floorList = doorService.getFloorList(paramMap);                           //층 목록

        List<HashMap> schDoorGroupList = doorGroupService.getSchDoorGroupList(paramMap);        // 스케쥴 목록
        List<HashMap> doorAlarmGrpList = doorAlarmService.getDoorAlarmGrpList(paramMap);        // 출입물 알람 그룹 목록

        model.addAttribute("workplaceList", workplaceList);
        model.addAttribute("buildingList", buildingList);
       // model.addAttribute("areaList", areaList);
        model.addAttribute("floorList", floorList);
        model.addAttribute("doorAlarmGrpList", doorAlarmGrpList);
        model.addAttribute("schDoorGroupList", schDoorGroupList);
        //model.addAttribute("scheduleList", scheduleList);

        return "cubox/door/doorManagementDetail";
    }


    /**
     * 출입문 목록 조회
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/list.do", method = RequestMethod.GET)
    public ModelAndView getDoorList(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String keyword = StringUtil.nvl(commandMap.get("keyword"), "");
        HashMap parmaMap = new HashMap();

        if( keyword.length() > 0 ){
            parmaMap.put("keyword",keyword);
        }

        List<Map> workplaceList = doorService.getWorkplaceList(parmaMap); //사업장 목록
        List<Map>  buildingList = doorService.getBuildingList(parmaMap);  //빌딩 목록
        //List<Map>      areaList = doorService.getAreaList(parmaMap);      //지역 목록
        List<HashMap> floorList = doorService.getFloorList(parmaMap);     //층 목록

        List<Map> doorList = doorService.getDoorList(parmaMap);           //출입문 목록

        model.addAttribute("workplaceList", workplaceList);
        model.addAttribute("buildingList", buildingList);
        //model.addAttribute("areaList", areaList);
        model.addAttribute("floorList", floorList);

        modelAndView.addObject("doorList", doorList);

        return modelAndView;
    }

    /**
     * 출입문 정보 상세 조회
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/detail.do", method = RequestMethod.GET)
    public ModelAndView getDoorInformation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        LOGGER.debug("getDoor");
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        LOGGER.debug("param doorId=" + commandMap.get("doorId"));
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("id", commandMap.get("doorId"));

        HashMap doorInfo = (HashMap) doorService.getDoorDetail(param); // TODO: 스케쥴 이름은 필요 없음

        modelAndView.addObject("doorInfo", doorInfo);

        return modelAndView;
    }

    /**
     * 출입문 정보 등록
     *
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/add.do", method = RequestMethod.POST)
    public ModelAndView addDoor( @RequestParam Map<String, Object> commandMap) throws Exception {
        LOGGER.debug("출입문 등록");

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String doorNm = StringUtil.nvl(commandMap.get("doorNm"), "");
        String doorCd = StringUtil.nvl(commandMap.get("doorCd"), "");
        String buildingId = StringUtil.nvl(commandMap.get("buildingId"), "");
        String buildingCd = doorService.getBuildingCd(buildingId);
        String floorId = StringUtil.nvl(commandMap.get("floorId"), "");
        String floorCd = doorService.getFloorCd(floorId);
        String alarmGroupId = StringUtil.nvl(commandMap.get("alarmGroupId"), "");
        String terminalIds = StringUtil.nvl(commandMap.get("terminalIds"), "");
        String authGrIds = StringUtil.isNullToString(commandMap.get("authGrIds"));
//        String areaId = StringUtil.nvl(commandMap.get("areaId"), "");
//        String doorGroupId = StringUtil.nvl(commandMap.get("doorGroupId"), "");
//        String scheduleId = StringUtil.nvl(commandMap.get("scheduleId"), "");

        HashMap param = new HashMap();

        param.put("doorNm", doorNm);                    //출입문 명
        param.put("doorCd", doorCd);                    //출입문 코드
        param.put("buildingId", buildingId);            //빌딩 ID
        param.put("buildingCd", buildingCd);            //빌딩 코드
        param.put("floorId", floorId);                  //층 ID
        param.put("floorCd", floorCd);                  //층 코드
        param.put("alarmGroupId", alarmGroupId);        //알람 그룹 ID
        param.put("terminalIds", terminalIds);          //단말기 ID - 복수저장?
        param.put("authGrIds", authGrIds);              //권한그룹ID - 복수저장?
//        param.put("areaId", areaId);                  //지역 ID
//        param.put("doorScheduleId", scheduleId);      //스케쥴 ID
//        param.put("doorGroupId", doorGroupId);        //출입문 스케쥴 ID

        String newDoorId = "";
        try {
            newDoorId = doorService.addDoor(param);
        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
        }
        modelAndView.addObject("newDoorId", newDoorId );
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }


    /**
     * 출입문 정보 수정
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/update.do", method = RequestMethod.POST)
    public ModelAndView updateDoor(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        HashMap param = new HashMap();

        if (StringUtil.isEmpty(commandMap.get("doorId").toString() ) ){
            modelAndView.addObject("resultCode", "N");
            modelAndView.addObject("resultMsg", "no id");
        } else {
            String doorId = commandMap.get("doorId").toString();
            String doorCd = commandMap.get("doorCd").toString();
            String doorNm = StringUtil.nvl(commandMap.get("doorNm"), "");
            String buildingId = StringUtil.nvl(commandMap.get("buildingId"), "");
            String buildingCd = doorService.getBuildingCd(buildingId);
            String floorId = StringUtil.nvl(commandMap.get("floorId"), "");
            String floorCd = doorService.getFloorCd(floorId);
            String alarmGroupId = StringUtil.nvl(commandMap.get("alarmGroupId"), "");
            String terminalIds = StringUtil.nvl(commandMap.get("terminalIds"), "");
            String authGrIds = StringUtil.nvl(commandMap.get("authGrIds"), "");
//            String areaId = StringUtil.nvl(commandMap.get("areaId"), "");
//            String doorGroupId = StringUtil.nvl(commandMap.get("doorGroupId"), "");
//            String scheduleId = StringUtil.nvl(commandMap.get("scheduleId"), "");

            param.put("id", doorId);
            param.put("doorCd", doorCd);
            param.put("doorNm", doorNm);
            param.put("buildingId", buildingId);
            param.put("buildingCd", buildingCd);
            param.put("floorId", floorId);
            param.put("floorCd", floorCd);
            param.put("alarmGroupId", alarmGroupId);
            param.put("terminalIds", terminalIds);
            param.put("authGrIds", authGrIds);
//            param.put("areaId", areaId);
//            param.put("doorScheduleId", scheduleId);
//            param.put("doorGroupId", doorGroupId);
        }
        try {
            doorService.updateDoor(param);
            modelAndView.addObject("resultCode", "Y");
        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
            modelAndView.addObject("resultMsg", e.getStackTrace());
        }


        return modelAndView;
    }


    /**
     * 출입문 삭제
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/delete.do", method = RequestMethod.POST)
    public ModelAndView deleteDoor(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        try {
            doorService.deleteDoor(commandMap);
        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
        }
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }



    /**
     * 단말기 목록 조회(검색)
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/terminal/list.do", method = RequestMethod.GET)
    public ModelAndView searchTerminal(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        try {

            String keyword = StringUtil.nvl(commandMap.get("keyword"), "");
            String registrationionStatus = StringUtil.nvl(commandMap.get("registrationionStatus"), "");

            HashMap param = new HashMap<>();

            if (keyword.length() > 0) {
                param.put("keyword", keyword);
            }

            if (registrationionStatus.length() > 0) {
                param.put("registrationionStatus", registrationionStatus);

            }

            List<HashMap> terminalList = doorService.getTerminalList(param);
            model.addAttribute("terminalList", terminalList);

        } catch (Exception e) {
            e.printStackTrace();
            modelAndView.addObject("message", e.getMessage());
        }

        return modelAndView;
    }


    // 일괄 등록 양식 다운로드(출입문)
    @RequestMapping(value = "/batch/registrationForm.do")
    public ModelAndView downloadRegistrationForm(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        return modelAndView;
    }

    // 일괄 등록 (출입문 Excel)
    @RequestMapping(value = "/batch/insert.do")
    public ModelAndView insertBatch(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        return modelAndView;
    }


    /**
     * 구역 목록 조회
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/area/list.do", method = RequestMethod.GET)
    public ModelAndView getAreaList(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        List<HashMap> areaList = doorService.getAreaList(commandMap);

        modelAndView.addObject("areaList", areaList);

        return modelAndView;
    }

    /**
     * 층 목록 조회
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/floor/list.do", method = RequestMethod.GET)
    public ModelAndView getFloorList(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        List<HashMap> floorList = doorService.getFloorList(commandMap);

        modelAndView.addObject("floorList", floorList);

        return modelAndView;
    }

    /**
     * 권한 그룹 목록 조회
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/authGroup/list.do", method = RequestMethod.GET)
    public ModelAndView getAuthList(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        AuthVO vo = new AuthVO();

        String keyword = StringUtil.nvl(commandMap.get("keyword"), "");
        String srchCond = StringUtil.nvl(commandMap.get("authType"), "");

        vo.setKeyword(keyword);
        vo.setSrchCond(srchCond);
        List<AuthVO> authList = authService.getAuthList(vo);

        modelAndView.addObject("authList", authList);

        return modelAndView;
    }


    /**
     * 빌딩 추가
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/building/add.do", method = RequestMethod.POST)
    public ModelAndView addBuilding( @RequestParam Map<String, Object> commandMap) throws Exception {
        LOGGER.debug("빌딩 추가");

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String  buildingCd = StringUtil.nvl(commandMap.get("buildingCd"), "");
        String  buildingNm = StringUtil.nvl(commandMap.get("buildingNm"), "");
        String workplaceId = StringUtil.nvl(commandMap.get("workplaceId"), "");

        HashMap param = new HashMap();

        param.put("buildingCd", buildingCd);        //빌딩 코드
        param.put("buildingNm", buildingNm);        //빌딩 명
        param.put("workplaceId", workplaceId);//빌딩 ID

        String newBuildingId = "";
        try {
            newBuildingId = doorService.addBuilding(param);
        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
        }
        modelAndView.addObject("newBuildingId", newBuildingId);
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }

    /**
     * 구역 추가
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/area/add.do", method = RequestMethod.POST)
    public ModelAndView addArea( @RequestParam Map<String, Object> commandMap) throws Exception {
        LOGGER.debug("구역 추가");

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String areaNm = StringUtil.nvl(commandMap.get("areaNm"), "");;
        String buildingId = StringUtil.nvl(commandMap.get("buildingId"), "");

        HashMap param = new HashMap();

        param.put("areaNm", areaNm);        //출입문 명
        param.put("buildingId", buildingId);//빌딩 ID

        String newAreaId = "";
        try {
            newAreaId = doorService.addArea(param);
        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
        }
        modelAndView.addObject("newAreaId", newAreaId );
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }

    /**
     * 층 추가
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/floor/add.do", method = RequestMethod.POST)
    public ModelAndView addFloor( @RequestParam Map<String, Object> commandMap) throws Exception {
        LOGGER.debug("층 추가");

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String floorNm = StringUtil.nvl(commandMap.get("floorNm"), "");;
        String buildingCd = StringUtil.nvl(commandMap.get("buildingCd"), "");
        String floorCd = StringUtil.nvl(commandMap.get("floorCd"), "");
        String buildingId = StringUtil.nvl(commandMap.get("buildingId"), "");
        //String areaId = StringUtil.nvl(commandMap.get("areaId"), "");

        HashMap param = new HashMap();

        param.put("floorNm", floorNm);        //출입문 명
        param.put("buildingId", buildingId);  //빌딩 ID
        param.put("buildingCd", buildingCd);  //빌딩 코드
        param.put("floorCd", floorCd);        //층 코드
        //param.put("areaId", areaId);        //지역 ID

        String newfloorId = "";
        try {
            newfloorId = doorService.addFloor(param);
        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
        }
        modelAndView.addObject("newfloorId", newfloorId );
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }


    @RequestMapping(value = "/building/detail.do", method = RequestMethod.GET)
    public ModelAndView getBuildingInformation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        LOGGER.debug("getBuildingInformation");
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        LOGGER.debug("param buildingId=" + commandMap.get("buildingId"));
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("id", commandMap.get("buildingId"));

        HashMap doorInfo = (HashMap) doorService.getBuildingDetail(param);

        modelAndView.addObject("doorInfo", doorInfo);

        return modelAndView;
    }


    @RequestMapping(value = "/floor/detail.do", method = RequestMethod.GET)
    public ModelAndView getFloorInformation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        LOGGER.debug("getFloorInformation");
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        LOGGER.debug("param floorId=" + commandMap.get("floorId"));
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("id", commandMap.get("floorId"));

        HashMap doorInfo = (HashMap) doorService.getFloorDetail(param);

        modelAndView.addObject("doorInfo", doorInfo);

        return modelAndView;
    }

    @RequestMapping(value = "/area/detail.do", method = RequestMethod.GET)
    public ModelAndView getArearInformation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        LOGGER.debug("getArearInformation");
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        LOGGER.debug("param areaId=" + commandMap.get("areaId"));
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("id", commandMap.get("areaId"));

        HashMap doorInfo = (HashMap) doorService.getAreaDetail(param);

        modelAndView.addObject("doorInfo", doorInfo);

        return modelAndView;
    }

    /**
     * 빌딩 수정
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/building/update.do", method = RequestMethod.POST)
    public ModelAndView updateBuilding(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        HashMap param = new HashMap();

        if (StringUtil.isEmpty(commandMap.get("buildingId").toString())) {
            modelAndView.addObject("resultCode", "N");
            modelAndView.addObject("resultMsg", "no id");
        } else {
            String buildingId = StringUtil.nvl(commandMap.get("buildingId"), "");
            String buildingNm = StringUtil.nvl(commandMap.get("buildingNm"), "");
            String buildingCd = StringUtil.nvl(commandMap.get("buildingCd"), "");
            String workplaceId = StringUtil.nvl(commandMap.get("workplaceId"), "");
//            String authGrIds = StringUtil.nvl(commandMap.get("authGrIds"), "");

            param.put("id", buildingId);
            param.put("buildingNm", buildingNm);
            param.put("buildingCd", buildingCd);
            param.put("workplaceId", workplaceId);
//            param.put("authGrIds", authGrIds);
        }
        try {
            doorService.updateBuilding(param);

        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
            modelAndView.addObject("resultMsg", e.getStackTrace());
        }
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }


    /**
     * 빌딩 삭제
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/building/delete.do", method = RequestMethod.POST)
    public ModelAndView deleteBuilding(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        try {
            doorService.deleteBuilding(commandMap);
        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
        }
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }

    /**
     * 구역 수정
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/area/update.do", method = RequestMethod.POST)
    public ModelAndView updateArea(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        HashMap param = new HashMap();

        if (StringUtil.isEmpty(commandMap.get("areaId").toString() ) ){
            modelAndView.addObject("resultCode", "N");
            modelAndView.addObject("resultMsg", "no id");
        } else {
            String areaId = StringUtil.nvl(commandMap.get("areaId"), "");
            String areaNm = StringUtil.nvl(commandMap.get("areaNm"), "");;
            String buildingId = StringUtil.nvl(commandMap.get("buildingId"), "");;


            param.put("areaId", areaId);
            param.put("areaNm", areaNm);
            param.put("buildingId", buildingId);
        }
        try {
            doorService.updateArea(param);

        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
            modelAndView.addObject("resultMsg", e.getStackTrace());
        }
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }


    /**
     * 빌딩 삭제
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/area/delete.do", method = RequestMethod.POST)
    public ModelAndView deleteArea(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        try {
            doorService.deleteArea(commandMap);
        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
        }
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }

    /**
     *  수정
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/floor/update.do", method = RequestMethod.POST)
    public ModelAndView updateFloor(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        HashMap param = new HashMap();

        if (StringUtil.isEmpty(commandMap.get("floorId").toString() ) ){
            modelAndView.addObject("resultCode", "N");
            modelAndView.addObject("resultMsg", "no id");
        } else {
            String floorId = StringUtil.nvl(commandMap.get("floorId"), "");
            String floorNm = StringUtil.nvl(commandMap.get("floorNm"), "");
            String floorCd = StringUtil.nvl(commandMap.get("floorCd"), "");
            String buildingId = StringUtil.nvl(commandMap.get("buildingId"), "");
            //String areaId = StringUtil.nvl(commandMap.get("areaId"), "");

            param.put("id", floorId);
            param.put("floorNm", floorNm);
            param.put("floorCd", floorCd);
            param.put("buildingId", buildingId);
            //param.put("areaId", areaId);
        }

        try {
            doorService.updateFloor(param);

        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
            modelAndView.addObject("resultMsg", e.getStackTrace());
        }
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }


    /**
     * floor 삭제
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/floor/delete.do", method = RequestMethod.POST)
    public ModelAndView deleteFloor(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        try {
            doorService.deleteFloor(commandMap);
        } catch (Exception e) {
            e.getStackTrace();
            modelAndView.addObject("resultCode", "N");
        }
        modelAndView.addObject("resultCode", "Y");

        return modelAndView;
    }


    @RequestMapping(value = "/terminal/confirmUse.do", method = RequestMethod.GET)
    public ModelAndView getTerminalConfirmUse(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("id", commandMap.get("terminalId"));

        int terminalUseCnt = doorService.getTerminalUseCnt(param);

        modelAndView.addObject("terminalUseCnt", terminalUseCnt);

        return modelAndView;
    }

    @RequestMapping(value = "/building/name/verification.do", method = RequestMethod.GET)
    public ModelAndView getBuildingNameValidation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("buildingNm", commandMap.get("buildingNm"));

        int buildingNameVerificationCnt = doorService.getBuildingNameVerification(param);

        modelAndView.addObject("buildingNameVerificationCnt", buildingNameVerificationCnt);

        return modelAndView;
    }


    @RequestMapping(value = "/area/name/verification.do", method = RequestMethod.GET)
    public ModelAndView getAreaNameValidation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("areaNm", commandMap.get("areaNm"));

        int areaNameVerificationCnt = doorService.getAreaNameVerification(param);

        modelAndView.addObject("areaNameVerificationCnt", areaNameVerificationCnt);

        return modelAndView;
    }


    @RequestMapping(value = "/floor/name/verification.do", method = RequestMethod.GET)
    public ModelAndView getFloorNameValidation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("floorNm", commandMap.get("floorNm"));

        int floorNameVerificationCnt = doorService.getFloorNameVerification(param);

        modelAndView.addObject("floorNameVerificationCnt", floorNameVerificationCnt);

        return modelAndView;
    }


    @RequestMapping(value = "/name/verification.do", method = RequestMethod.GET)
    public ModelAndView getDoorNameValidation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("doorNm", commandMap.get("doorNm"));

        int doorNameVerificationCnt = doorService.getDoorNameVerification(param);

        modelAndView.addObject("doorNameVerificationCnt", doorNameVerificationCnt);

        return modelAndView;
    }


    @ResponseBody
    @RequestMapping(value = "/excel/upload.do", method = RequestMethod.POST)
    public ModelAndView excelUpload(MultipartHttpServletRequest request) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        MultipartFile file = null;

        Iterator<String> iterator = request.getFileNames();
        if (iterator.hasNext()) {
            file = request.getFile(iterator.next());
        }
        LOGGER.debug("File === ", file);

        try {
            Workbook wb = WorkbookFactory.create(file.getInputStream());
            Sheet sheet = wb.getSheetAt(0);

            // validation
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                String buildingNm = getValue(row.getCell(1)).replaceAll("\n", "<br>");              // 빌딩 명
                String buildingCd = getValue(row.getCell(5)).replaceAll("\n", "<br>");              // 빌딩 코드
                String floorNm = getValue(row.getCell(2)).replaceAll("\n", "<br>");                 // 층 명
                String floorCd = getValue(row.getCell(6)).replaceAll("\n", "<br>");                 // 층 코드
                String doorNm = getValue(row.getCell(3)).replaceAll("\n", "<br>");                  // 출입문 명
                String doorCd = getValue(row.getCell(7)).replaceAll("\n", "<br>");                  // 출입문 코드
                String terminalCd = getValue(row.getCell(4)).replaceAll("\n", "<br>");              // 단말기 코드

                String errorMsg = validExcel(buildingNm, buildingCd, floorNm, floorCd, doorNm, doorCd, terminalCd);
                if (!errorMsg.equals("")) {
                    modelAndView.addObject("resultCode", "N");
                    modelAndView.addObject("message", errorMsg);
                    return modelAndView;
                }
            }

            // Building Floor Door 등록
            int doorCnt = doorService.addBuildingFloorDoor(sheet);

            if (doorCnt > 0) {
                if (doorCnt == sheet.getLastRowNum()) {
                    modelAndView.addObject("resultCode", "Y");
                    modelAndView.addObject("message", "Success");
                } else {
                    modelAndView.addObject("resultCode", "N");
                    modelAndView.addObject("message", "Fail - 출입문 갯수 불일치");
                }
            } else if (doorCnt == -1) {
                String errorMsg = "=== ErrorCode (" + ED03 + ") ===\n중복된 출입문 코드가 있습니다. \n관리자에게 문의하세요.";
                modelAndView.addObject("resultCode", "N");
                modelAndView.addObject("message", errorMsg);
            } else {
                modelAndView.addObject("resultCode", "N");
                modelAndView.addObject("message", "Fail - 출입문이 등록되지 않음");
            }

        } catch (Exception e) {
            modelAndView.addObject("resultCode", "N");
            modelAndView.addObject("message", e);
            e.printStackTrace();
        }

        return modelAndView;
    }


    public String validExcel(String buildingNm, String buildingCd, String floorNm, String floorCd, String doorNm, String doorCd, String terminalCd) {
        String errorMsg = "";

        if (buildingNm.equals("") || buildingNm == null) {
            errorMsg = "=== ErrorCode (" + EB01 + ") ===\n빌딩 이름이 누락되었습니다. \n관리자에게 문의하세요.";
        } else if (buildingCd.equals("") || buildingCd == null) {
            errorMsg = "=== ErrorCode (" + EB02 + ") ===\n빌딩 코드가 누락되었습니다. \n관리자에게 문의하세요.";
        } else if (floorNm.equals("") || floorNm == null) {
            errorMsg = "=== ErrorCode (" + EF01 + ") ===\n층 이름이 누락되었습니다. \n관리자에게 문의하세요.";
        } else if (floorCd.equals("") || floorCd == null) {
            errorMsg = "=== ErrorCode (" + EF02 + ") ===\n층 코드가 누락되었습니다. \n관리자에게 문의하세요.";
        } else if (doorNm.equals("") || doorNm == null) {
            errorMsg = "=== ErrorCode (" + ED01 + ") ===\n출입문 이름이 누락되었습니다. \n관리자에게 문의하세요.";
        } else if (doorCd.equals("") || doorCd == null) {
            errorMsg = "=== ErrorCode (" + ED02 + ") ===\n출입문 코드가 누락되었습니다. \n관리자에게 문의하세요.";
        } else if (terminalCd.equals("") || terminalCd == null) {
            System.out.println("터미널코드 누락");
        }

        return errorMsg;
    }


    public static String getValue(Cell cell) {
        String value = "";

        if (cell == null) {
            value = "";
        } else {
            switch (cell.getCellType()) {
                case Cell.CELL_TYPE_FORMULA:
                    value = cell.getCellFormula();
                    break;
                case Cell.CELL_TYPE_NUMERIC:
                    value = String.valueOf((long)cell.getNumericCellValue());
                    // TODO: Date타입 format처리
                    break;
                case Cell.CELL_TYPE_STRING:
                    value = cell.getStringCellValue();
                    break;
                case Cell.CELL_TYPE_BOOLEAN:
                    value = cell.getBooleanCellValue() + "";
                    break;
                case Cell.CELL_TYPE_ERROR:
                    value = cell.getErrorCellValue() + "";
                    break;
                case Cell.CELL_TYPE_BLANK:
                    value = "";
                    break;
                default:
                    value = cell.getStringCellValue();
            }
        }
        return value;
    }


    @RequestMapping(value = "/excel/download.do", method = RequestMethod.GET)
    public ModelAndView excelFormDownload(@RequestParam Map<String, Object> commandMap, HttpServletRequest request) throws Exception {

        String filePath = request.getSession().getServletContext().getRealPath("/excel/");
        // C:\Dev\IdeaProjects\CUBOX_ACS_Admin\target\CUBOX_ACS_Admin\excel\

        File downloadFile = new File(filePath + "excelupload_door_sample.xlsx");
        String fileOrigin = "엑셀업로드_출입문_양식샘플.xlsx";

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("fileDownloadView");
        modelAndView.addObject("downloadFile", downloadFile);
        modelAndView.addObject("fileOrigin", fileOrigin);

        return modelAndView;
    }



}
