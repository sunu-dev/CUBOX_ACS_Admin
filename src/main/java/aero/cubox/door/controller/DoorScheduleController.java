package aero.cubox.door.controller;

import aero.cubox.cmmn.service.CommonService;
import aero.cubox.core.vo.PaginationVO;
import aero.cubox.door.service.DoorGroupService;
import aero.cubox.door.service.DoorScheduleService;
import aero.cubox.door.service.DoorService;
import aero.cubox.util.CommonUtils;
import aero.cubox.util.StringUtil;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
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
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static aero.cubox.util.JsonUtil.getListMapFromJsonArray;
import static org.springmodules.validation.util.condition.Conditions.notEmpty;

@Controller
@RequestMapping(value = "/door/schedule/")
public class DoorScheduleController {

    @Resource(name = "commonUtils")
    private CommonUtils commonUtils;

    @Resource(name = "commonService")
    private CommonService commonService;

    @Resource(name = "doorService")
    private DoorService doorService;

    @Resource(name = "doorScheduleService")
    private DoorScheduleService doorScheduleService;

    @Resource(name = "doorGroupService")
    private DoorGroupService doorGroupService;


    private static final Logger LOGGER = LoggerFactory.getLogger(DoorScheduleController.class);

    private int curPageUnit= 10; //한번에 표시할 페이지 번호 개수
    private String initSrchRecPerPage = "10"; //한번에 표시할 페이지 번호 개수

    public int autoOffset(int srchPage, int srchCnt ){
        int off = (srchPage - 1) * srchCnt;
        if(off<0) off = 0;
        return off;
    }

    /**
     * 스케줄 관리 - view
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/list.do")
    public String showScheduleList(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        //todo 세션
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

            List<HashMap> doorScheduleList = doorScheduleService.getDoorScheduleList(paramMap);
            int totalCnt = doorScheduleService.getDoorScheduleListCount(paramMap);

            PaginationVO pageVO = new PaginationVO();
            pageVO.setCurPage(srchPage);
            pageVO.setRecPerPage(srchRecPerPage);
            pageVO.setTotRecord(totalCnt);
            pageVO.setUnitPage(curPageUnit);
            pageVO.calcPageList();

            model.addAttribute("doorScheduleList", doorScheduleList);
            model.addAttribute("keyword", keyword);
            model.addAttribute("pagination", pageVO);

        } catch (Exception e){
            e.printStackTrace();
            modelAndView.addObject("message", e.getMessage());
        }

        return "cubox/door/schedule/list";
    }


    /**
     * 스케줄 목록 조회 Ajax
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/listAjax.do", method = RequestMethod.GET)
    public ModelAndView getScheduleList(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        //todo 세션
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

            List<HashMap> doorScheduleList = doorScheduleService.getDoorScheduleList(paramMap);
            int totalCnt = doorScheduleService.getDoorScheduleListCount(paramMap);

            PaginationVO pageVO = new PaginationVO();
            pageVO.setCurPage(srchPage);
            pageVO.setRecPerPage(srchRecPerPage);
            pageVO.setTotRecord(totalCnt);
            pageVO.setUnitPage(curPageUnit);
            pageVO.calcPageList();

            model.addAttribute("doorScheduleList", doorScheduleList);
            model.addAttribute("keyword", keyword);
            model.addAttribute("pagination", pageVO);

        } catch (Exception e){
            e.printStackTrace();
            modelAndView.addObject("message", e.getMessage());
        }

        return modelAndView;
    }

    
    /**
     * 스케쥴 등록 View
     *
     * @param model
     * @param commandMap
     * @param redirectAttributes
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/add.do", method = RequestMethod.GET)
    public String showScheduleAddView(ModelMap model, @RequestParam Map<String, Object> commandMap, RedirectAttributes redirectAttributes) throws Exception {

        HashMap<String, Object> paramMap = new HashMap();
        List<HashMap> schDoorGroupList = doorGroupService.getSchDoorGroupList(paramMap);

        model.addAttribute("schDoorGroupList", schDoorGroupList);
        return "cubox/door/schedule/add";
    }

    /**
     * 출입문 스케쥴 상세
     * @param model
     * @param id
     * @param request
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/detail/{id}", method = RequestMethod.GET)
    public String detail(ModelMap model, @PathVariable int id, HttpServletRequest request) throws Exception {

        HashMap<String, Object> paramMap = new HashMap();
        paramMap.put("doorSchId", id);

        HashMap doorScheduleDetail = doorScheduleService.getDoorScheduleDetail(id);
        List<HashMap> schDoorGroupList = doorGroupService.getSchDoorGroupList(paramMap);

        model.addAttribute("doorScheduleDetail", doorScheduleDetail);
        model.addAttribute("schDoorGroupList", schDoorGroupList);

        return "cubox/door/schedule/detail";
    }

    /**
     * 출입문 스케쥴 저장
     * @param model
     * @param commandMap
     * @param redirectAttributes
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/save.do", method = RequestMethod.POST)
    public ModelAndView saveSchedule(ModelMap model, @RequestParam Map<String, Object> commandMap, RedirectAttributes redirectAttributes) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "Y";
        String newScheduleId = "";

        String nm = StringUtil.nvl(commandMap.get("nm"), "");
        String doorGroupIds = StringUtil.nvl(commandMap.get("doorGroupIds"), "");


        HashMap param = new HashMap();

        param.put("doorSchNm", nm);
        param.put("doorGroupIds", doorGroupIds);

        try {
            newScheduleId = doorScheduleService.addSchedule(param);
        } catch (Exception e) {
            e.getStackTrace();
            resultCode = "N";
        }

        modelAndView.addObject("resultCode", resultCode);
        modelAndView.addObject("newScheduleId", newScheduleId);

        return modelAndView;
    }


    /**
     * 출입문 스케쥴 수정
     * @param model
     * @param id
     * @param request
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value="/modify/{id}", method= RequestMethod.POST)
    public ModelAndView modify(ModelMap model, @PathVariable String id, HttpServletRequest request,@RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "Y";

        if( !CommonUtils.notEmpty(id) ){
            resultCode = "N";
            model.addAttribute("resultCode", resultCode);
            modelAndView.addObject("resultMsg", "no id");
            return modelAndView;
        }

        String scheduleId = StringUtil.nvl(id);
        String doorSchNm = StringUtil.nvl(commandMap.get("doorSchNm"), "");
        String useYn = StringUtil.nvl(commandMap.get("useYn"), "");
        String doorGroupIds = StringUtil.nvl(commandMap.get("doorGroupIds"), "");

        HashMap param = new HashMap();

        param.put("id", scheduleId);

        if( CommonUtils.notEmpty(doorSchNm) ){
            param.put("doorSchNm", doorSchNm);
        }

        if( CommonUtils.notEmpty(useYn) ){
            param.put("useYn", useYn);
        }

        param.put("doorGroupIds", doorGroupIds);

        try {
            doorScheduleService.updateSchedule(param);

        } catch (Exception e) {
            e.getStackTrace();
            resultCode = "N";
        }

        model.addAttribute("resultCode", resultCode);

        return modelAndView;
    }

    /**
     * 스케줄 삭제
     *
     * @param model
     * @param commandMap
     * @param redirectAttributes
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/delete/{id}")
    public ModelAndView deleteSchedule(ModelMap model, @PathVariable int id,@RequestParam Map<String, Object> commandMap, RedirectAttributes redirectAttributes) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "N";

        commandMap.put("id", id);

        try {
            doorScheduleService.deleteSchedule(commandMap);
            resultCode = "Y";
        } catch (Exception e) {
            e.getStackTrace();
        }

        model.addAttribute("resultCode", resultCode);
        return modelAndView;
    }



    /**
     * 요일별 스케쥴 등록
     * @param commandMap
     * @param request
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/day/add.do", method = RequestMethod.POST)
    public ModelAndView addScheduleByDay(@RequestParam Map<String, Object> commandMap, HttpServletRequest request) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "Y";

        JSONParser parser = new JSONParser();
        Object obj = parser.parse((String) commandMap.get("day_schedule"));

        List<Map<String, Object>> dayScheduleList = getListMapFromJsonArray((JSONArray) obj);

        if( dayScheduleList.size() > 0 ){

            try {

                for (int i = 0; i < dayScheduleList.size(); i++) {
                    Map<String, Object> dayScheduleParam = dayScheduleList.get(i);
                    dayScheduleParam.put("doorSchId", commandMap.get("doorSchId"));

                    String[] dayScheduleOrder = dayScheduleParam.get("id").toString().split("_");
                    dayScheduleParam.put("orderNo", dayScheduleOrder[1]);
                    dayScheduleParam.put("begTm", dayScheduleParam.get("beg_tm"));
                    dayScheduleParam.put("endTm", dayScheduleParam.get("end_tm"));
                    doorScheduleService.addScheduleByDay(dayScheduleParam);
                }
            } catch (Exception e) {
                e.getStackTrace();
                resultCode = "N";
            }
        } else {
            resultCode = "N";
        }
        modelAndView.addObject("resultCode", resultCode);

        return modelAndView;
    }

    /**
     * 요일별 스케쥴 조회
     * @param model
     * @param id : 스케쥴 아이디 (door_sch_id)
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/day/detail/{id}", method = RequestMethod.POST)
    public ModelAndView getScheduleByDay(ModelMap model, @PathVariable String id) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "N";

        if( id != null ){
            HashMap paramMap = new HashMap();

            paramMap.put("doorSchId", id);

            try {
                List<HashMap> scheduleByDayDetailList = doorScheduleService.getScheduleByDayDetailList(paramMap);
                resultCode = "Y";
                modelAndView.addObject("scheduleByDayDetailList", scheduleByDayDetailList);
            } catch (Exception e){
                e.getStackTrace();
                resultCode = "N";
            }
        }

        modelAndView.addObject("resultCode", resultCode);

        return modelAndView;
    }


    /**
     * 출입문 요일별 스케쥴 수정
     * @param model
     * @param id
     * @param request
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value="/day/modify/{id}", method= RequestMethod.POST)
    public ModelAndView modifyScheduleByDay(ModelMap model, @PathVariable String id, HttpServletRequest request,@RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "Y";

        if( id == null){
            resultCode = "N";
            model.addAttribute("resultCode", resultCode);

            return modelAndView;
        }

        JSONParser parser = new JSONParser();
        Object obj = parser.parse((String) commandMap.get("day_schedule"));


        List<Map<String, Object>> dayScheduleList = getListMapFromJsonArray((JSONArray) obj);

        if( dayScheduleList.size() > 0 ){

            try {
                Map<String, Object> dayScheduleParam;

                doorScheduleService.deleteScheduleByDay(commandMap);
                
                for (int i = 0; i < dayScheduleList.size(); i++) {
                    dayScheduleParam = dayScheduleList.get(i);
                    dayScheduleParam.put("doorSchId", commandMap.get("doorSchId"));

                    if( dayScheduleList.size() > 0 ){
                        String[] dayScheduleOrder = dayScheduleList.get(i).get("id").toString().split("_");
                        dayScheduleParam.put("orderNo", dayScheduleOrder[1]);
                    }
                    dayScheduleParam.put("begTm", dayScheduleParam.get("beg_tm"));
                    dayScheduleParam.put("endTm", dayScheduleParam.get("end_tm"));

                    doorScheduleService.updateScheduleByDay(dayScheduleParam);
                    dayScheduleParam.clear();
                }
            } catch (Exception e) {
                e.getStackTrace();
                resultCode = "N";
            }
        } else {
            resultCode = "N";
        }

        model.addAttribute("resultCode", resultCode);

        return modelAndView;
    }

    /**
     * 출입문 요일별 스케쥴 삭제
     * @param model
     * @param id
     * @param request
     * @param commandMap
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value="/day/delete/{id}", method= RequestMethod.POST)
    public ModelAndView deleteScheduleByDay(ModelMap model, @PathVariable String id, HttpServletRequest request,@RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "Y";

        if( id == null){
            resultCode = "N";
            model.addAttribute("resultCode", resultCode);

            return modelAndView;
        }

        HashMap<String, Object> paramMap = new HashMap<>();

        paramMap.put("doorSchId", id);

        doorScheduleService.deleteScheduleByDay(paramMap);

        model.addAttribute("resultCode", resultCode);

        return modelAndView;
    }

    /**
     * 스케줄명 validation
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/name/verification.do", method = RequestMethod.GET)
    public ModelAndView getDoorScheduleNameValidation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("doorGroupNm", commandMap.get("doorGroupNm"));

        int doorScheduleNameVerificationCnt = doorScheduleService.getDoorScheduleNameVerification(param);

        modelAndView.addObject("doorScheduleNameVerificationCnt", doorScheduleNameVerificationCnt);

        return modelAndView;
    }

    /**
     * 출입문 그룹 목록 조회 ajax
     * @param model
     * @param commandMap
     * @param redirectAttributes
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value = "/group/listAjax.do", method = RequestMethod.POST)
    public ModelAndView getGroupListAjax(ModelMap model, @RequestParam Map<String, Object> commandMap, RedirectAttributes redirectAttributes) throws Exception {

        //todo 세션
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        try {

            HashMap<String, Object> paramMap = new HashMap();

            List<HashMap> doorGroupList = doorGroupService.getSchDoorGroupList(paramMap);

            model.addAttribute("doorGroupList", doorGroupList);

        } catch (Exception e){
            e.printStackTrace();
            modelAndView.addObject("message", e.getMessage());
        }

        return modelAndView;
    }

    /**
     * 스케줄명 validation
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/day/existsCount.do", method = RequestMethod.GET)
    public ModelAndView getDayScheduleExistsCount(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        try {
            int getDayScheduleExistsCount = doorScheduleService.getDayScheduleExistsCount(commandMap);
            modelAndView.addObject("getDayScheduleExistsCount", getDayScheduleExistsCount);
        } catch (Exception e){
            e.getStackTrace();
            modelAndView.addObject("message", e.getMessage());
        }

        return modelAndView;
    }

    public static String readBody(HttpServletRequest request) throws IOException {
        BufferedReader input = new BufferedReader(new InputStreamReader(request.getInputStream()));
        StringBuilder builder = new StringBuilder();

        String buffer;
        while ((buffer = input.readLine()) != null) {
            if (builder.length() > 0) {
                builder.append("\n");
            }
            builder.append(buffer);
        }
        return builder.toString();
    }

    @RequestMapping(value="/excel/download.do", method = RequestMethod.GET)
    public void excelDownloadSchedule(ModelMap model, @RequestParam Map<String, Object> commandMap, HttpServletResponse response) throws Exception {

        HashMap<String, Object> paramMap = new HashMap();
        List<HashMap> doorScheduleList = doorScheduleService.getDoorScheduleList(paramMap);

        ///// Create Excel /////
        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet();
        Row row = null;
        Cell cell = null;
        int rowNum = 0;

        //// Header ////
        final String[] colNames = {"번호", "출입문 스케쥴명", "사용", "등록일자", "수정일자"};
        // Header size
        final int[] colWidths = {1500, 6000, 3000, 3500, 3500};
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
        row.setHeight((short)500);

        for (int i = 0; i < colNames.length; i++) {
            cell = row.createCell(i);
            cell.setCellValue(colNames[i]);
            cell.setCellStyle(styleHeader);
            sheet.setColumnWidth(i, colWidths[i]);
        }

        // Body
        for (int i = 0; i < doorScheduleList.size(); i++) {
            row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(i + 1);
            row.createCell(1).setCellValue(doorScheduleList.get(i).get("door_sch_nm").toString());
            if (doorScheduleList.get(i).get("use_yn").toString().equals("Y")) {
                row.createCell(2).setCellValue("사용");
            } else {
                row.createCell(2).setCellValue("미사용");
            }
            if (doorScheduleList.get(i).containsKey("created_at")) {
                row.createCell(3).setCellValue(doorScheduleList.get(i).get("created_at").toString());
            }
            if (doorScheduleList.get(i).containsKey("updated_at")) {
                row.createCell(4).setCellValue(doorScheduleList.get(i).get("updated_at").toString());
            }
        }

        // Date
        SimpleDateFormat fmt = new SimpleDateFormat("yyMMdd-HH_mm_ss");
        Date date = new Date();

        // File name
        String fileNm = "출입문스케쥴목록_" + fmt.format(date) + ".xlsx";
        response.setContentType("ms-vnd/excel");
        response.setHeader("Content-Disposition", "attatchment;filename=" + URLEncoder.encode(fileNm, "UTF-8"));
        wb.write(response.getOutputStream());

    }
}
