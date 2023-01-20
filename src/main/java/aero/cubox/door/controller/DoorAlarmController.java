package aero.cubox.door.controller;

import aero.cubox.auth.service.AuthService;
import aero.cubox.cmmn.service.CommonService;
import aero.cubox.core.vo.PaginationVO;
import aero.cubox.door.service.DoorAlarmService;
import aero.cubox.door.service.DoorScheduleService;
import aero.cubox.door.service.DoorService;
import aero.cubox.terminal.service.TerminalService;
import aero.cubox.util.CommonUtils;
import aero.cubox.util.StringUtil;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Controller
@RequestMapping(value = "/door/alarm/")
public class DoorAlarmController {

    @Resource(name = "commonUtils")
    private CommonUtils commonUtils;

    @Resource(name = "commonService")
    private CommonService commonService;

    @Resource(name = "doorService")
    private DoorService doorService;

    @Resource(name = "doorAlarmService")
    private DoorAlarmService doorAlarmService;
    
    @Resource(name = "doorScheduleService")
    private DoorScheduleService doorScheduleService;

    @Resource(name = "terminalService")
    private TerminalService terminalService;

    @Resource(name = "authService")
    private AuthService authService;

    private static final Logger LOGGER = LoggerFactory.getLogger(DoorAlarmController.class);

    private int curPageUnit= 10; //한번에 표시할 페이지 번호 개수
    private String initSrchRecPerPage = "10"; //한번에 표시할 페이지 번호 개수

    public int autoOffset(int srchPage, int srchCnt ){
        int off = (srchPage - 1) * srchCnt;
        if(off<0) off = 0;
        return off;
    }
    /**
     * 출입문 알람 그룹 화면
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/list.do")
    public String showAlarmGroupList(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        try {
            int srchPage       = Integer.parseInt(StringUtil.nvl(commandMap.get("srchPage"), "1"));
            int srchRecPerPage = Integer.parseInt(StringUtil.nvl(commandMap.get("srchRecPerPage"), initSrchRecPerPage));
            String keyword = StringUtil.nvl(commandMap.get("keyword"), "");

            HashMap<String, Object> paramMap = new HashMap();

            paramMap.put("keyword", keyword);
            paramMap.put("srchCnt", srchRecPerPage);
            paramMap.put("offset", autoOffset(srchPage, srchRecPerPage));

            List<HashMap> doorAlarmGroupList = doorAlarmService.getDoorAlarmGrpList(paramMap);
            int totalCnt = doorAlarmService.getDoorAlarmGrpListCount(paramMap);

            PaginationVO pageVO = new PaginationVO();
            pageVO.setCurPage(srchPage);
            pageVO.setRecPerPage(srchRecPerPage);
            pageVO.setTotRecord(totalCnt);
            pageVO.setUnitPage(curPageUnit);
            pageVO.calcPageList();

            model.addAttribute("doorAlarmGroupList", doorAlarmGroupList);
            model.addAttribute("keyword", keyword);
            model.addAttribute("pagination", pageVO);

        } catch (Exception e){
            e.printStackTrace();
            modelAndView.addObject("message", e.getMessage());
        }

        return "cubox/door/alarm/list";
    }

    /**
     * 출입문 알람 그룹 목록 조회
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/listAjax.do", method = RequestMethod.GET)
    public ModelAndView getAlarmGroupListAjax(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String keyword = StringUtil.nvl(commandMap.get("keyword"), "");
        HashMap parmaMap = new HashMap();

        if( keyword.length() > 0){
            parmaMap.put("keyword",keyword);
        }

        List<HashMap> alarmGroupList = doorAlarmService.getDoorAlarmGrpList(parmaMap);
        modelAndView.addObject("alarmGroupList", alarmGroupList);

        return modelAndView;
    }




    // 출입문 알람 그룹 관리 상세
    @RequestMapping(value = "/detail/{id}", method = RequestMethod.GET)
    public String detail(ModelMap model, @PathVariable int id, HttpServletRequest request) throws Exception {

        HashMap doorGroupDetail = doorAlarmService.getDoorAlarmGrpDetail(id);
        List<HashMap> doorAlarmTypeList = doorAlarmService.getDoorAlarmTypeList();
        List<HashMap> alarmUseTypeList = doorAlarmService.getAlarmUseTypeList();

        HashMap parmaMap = new HashMap();
        List<HashMap> scheduleList = doorScheduleService.getDoorScheduleList(parmaMap);      // 스케쥴 목록

        model.addAttribute("doorGroupDetail", doorGroupDetail);
        model.addAttribute("doorAlarmTypeList", doorAlarmTypeList);
        model.addAttribute("alarmUseTypeList", alarmUseTypeList);

        return "cubox/door/alarm/detail";
    }


    // 출입문 알람 그룹 등록 화면
    @RequestMapping(value = "/add.do", method = RequestMethod.GET)
    public String showAlarmGroupAddView(ModelMap model, @RequestParam Map<String, Object> commandMap, RedirectAttributes redirectAttributes) throws Exception {

        List<HashMap> doorAlarmTypeList = doorAlarmService.getDoorAlarmTypeList();
        List<HashMap> alarmUseTypeList = doorAlarmService.getAlarmUseTypeList();

        model.addAttribute("doorAlarmTypeList", doorAlarmTypeList);
        model.addAttribute("alarmUseTypeList", alarmUseTypeList);

        return "cubox/door/alarm/add";
    }



    // 출입문 알람 그룹 등록
    @ResponseBody
    @RequestMapping(value = "/save.do", method = RequestMethod.POST)
    public ModelAndView addAlarmGroup(ModelMap model, @RequestParam Map<String, Object> commandMap, RedirectAttributes redirectAttributes) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "Y";
        String newDoorId = "";

        String nm = StringUtil.nvl(commandMap.get("nm"), "");
        String time = StringUtil.nvl(commandMap.get("time"), "0");
        String alarmUseType = StringUtil.nvl(commandMap.get("alarm_use_type"), "");
        String doorAlarmType = StringUtil.nvl(commandMap.get("door_alarm_type"), "");
        String doorIds = StringUtil.nvl(commandMap.get("doorIds"), "");

        HashMap param = new HashMap();

        param.put("nm", nm);
        param.put("time", time);
        param.put("alarmUseType", alarmUseType);
        param.put("doorAlarmType", doorAlarmType);
        param.put("doorIds", doorIds);

        try {
            newDoorId = doorAlarmService.addDoorAlarmGrp(param);
        } catch (Exception e) {
            e.getStackTrace();
            resultCode = "N";
        }

        modelAndView.addObject("resultCode", resultCode);
        modelAndView.addObject("newDoorId", newDoorId);

        return modelAndView;
    }


    @ResponseBody
    @RequestMapping(value="/modify/{id}", method= RequestMethod.POST)
    public ModelAndView modify(ModelMap model, @PathVariable String id, HttpServletRequest request,@RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "Y";

        if( id == null){
            resultCode = "N";
            model.addAttribute("resultCode", resultCode);

            return modelAndView;
        }

        String nm = StringUtil.nvl(commandMap.get("nm"), "");
        String time = StringUtil.nvl(commandMap.get("time"), "0");
        String alarmUseType = StringUtil.nvl(commandMap.get("alarm_use_type"), "");
        String doorAlarmType = StringUtil.nvl(commandMap.get("door_alarm_type"), "");
        String doorIds = StringUtil.nvl(commandMap.get("doorIds"), "");
//        String envYn = StringUtil.nvl(commandMap.get("envYn"), "");
//        String deleteYn = StringUtil.nvl(commandMap.get("deleteYn"), "");

        HashMap param = new HashMap();

        param.put("id", id);
        param.put("nm", nm);
        param.put("time", time);
        param.put("alarmUseType", alarmUseType);
        param.put("doorAlarmType", doorAlarmType);
        param.put("doorIds", doorIds);
//        param.put("envYn", envYn);
//        param.put("deleteYn", deleteYn);

        try {
            doorAlarmService.updateDoorAlarmGrp(param);

        } catch (Exception e) {
            e.getStackTrace();
            resultCode = "N";
        }
        model.addAttribute("resultCode", resultCode);

        return modelAndView;
    }

    @ResponseBody
    @RequestMapping(value="/delete/{id}")
    public ModelAndView delete(ModelMap model, @PathVariable int id, HttpServletRequest request) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        String resultCode = "Y";

        try {
            doorAlarmService.deleteDoorAlarmGrp(id);
        } catch (Exception e) {
            e.getStackTrace();
            resultCode = "N";
        }
        model.addAttribute("resultCode", resultCode);

        return modelAndView;
    }

    @RequestMapping(value = "/name/verification.do", method = RequestMethod.GET)
    public ModelAndView getDoorAlarmGroupNameValidation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("doorGroupNm", commandMap.get("doorGroupNm"));

        int doorAlarmGroupNameVerificationCnt = doorAlarmService.getDoorAlarmGroupNameVerification(param);

        modelAndView.addObject("doorAlarmGroupNameVerificationCnt", doorAlarmGroupNameVerificationCnt);

        return modelAndView;
    }


    @RequestMapping(value="/excel/download.do", method = RequestMethod.GET)
    public void excelDownloadAlarmGroup(ModelMap model, @RequestParam Map<String, Object> commandMap, HttpServletResponse response) throws Exception {

        HashMap<String, Object> paramMap = new HashMap();
        List<HashMap> doorAlarmGroupList = doorAlarmService.getDoorAlarmGrpList(paramMap);

        ///// Create Excel /////
        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet();
        Row row = null;
        Cell cell = null;
        int rowNum = 0;

        //// Header ////
        final String[] colNames = {"번호", "출입문 알람 그룹명", "유형", "시간", "출입문 수", "사용", "등록일자", "수정일자"};
        // Header size
        final int[] colWidths = {1500, 5000, 2000, 2000, 3000, 2000, 3500, 3500};
        // Header font
        Font fontHeader = wb.createFont();
        fontHeader.setBoldweight(Font.BOLDWEIGHT_BOLD);

        // Header style
        CellStyle styleHeader = wb.createCellStyle();
        styleHeader.setAlignment(CellStyle.ALIGN_CENTER);
        styleHeader.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
        styleHeader.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
        styleHeader.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
        styleHeader.setBorderLeft(HSSFCellStyle.BORDER_THIN);
        styleHeader.setBorderTop(HSSFCellStyle.BORDER_THIN);
        styleHeader.setBorderRight(HSSFCellStyle.BORDER_THIN);
        styleHeader.setBorderBottom(HSSFCellStyle.BORDER_THIN);
        styleHeader.setFont(fontHeader);

        row = sheet.createRow(rowNum++);
        row.setHeight((short)500);  // 행 높이

        for (int i = 0; i < colNames.length; i++) {
            cell = row.createCell(i);
            cell.setCellValue(colNames[i]);
            cell.setCellStyle(styleHeader);
            sheet.setColumnWidth(i, colWidths[i]);
        }

        //// Body ////
        for (int i = 0; i < doorAlarmGroupList.size(); i++) {
            row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(i + 1);
            row.createCell(1).setCellValue(doorAlarmGroupList.get(i).get("nm").toString());
            if (doorAlarmGroupList.get(i).get("env_yn").toString().equals("Y")) {
                row.createCell(2).setCellValue("사용");
            } else {
                row.createCell(2).setCellValue("미사용");
            }
            row.createCell(3).setCellValue(Integer.parseInt(doorAlarmGroupList.get(i).get("time").toString()));
            row.createCell(4).setCellValue(Integer.parseInt(doorAlarmGroupList.get(i).get("door_cnt").toString()));
            if (doorAlarmGroupList.get(i).get("delete_yn").toString().equals("Y")) {
                row.createCell(5).setCellValue("사용");
            } else {
                row.createCell(5).setCellValue("미사용");
            }
            if (doorAlarmGroupList.get(i).containsKey("created_at")) {
                row.createCell(6).setCellValue(doorAlarmGroupList.get(i).get("created_at").toString());
            }
            if (doorAlarmGroupList.get(i).containsKey("updated_at")) {
                row.createCell(7).setCellValue(doorAlarmGroupList.get(i).get("updated_at").toString());
            }
        }

        // Date
        SimpleDateFormat fmt = new SimpleDateFormat("yyMMdd-HH_mm_ss");
        Date date = new Date();

        // File name
        String fileNm = "출입문알람그룹목록_" + fmt.format(date) + ".xlsx";
        response.setContentType("ms-vnd/excel");
        response.setHeader("Content-Disposition", "attatchment;filename=" + URLEncoder.encode(fileNm, "UTF-8"));
        wb.write(response.getOutputStream());

    }


}
