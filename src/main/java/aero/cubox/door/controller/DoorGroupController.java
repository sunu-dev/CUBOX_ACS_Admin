package aero.cubox.door.controller;

import aero.cubox.auth.service.AuthService;
import aero.cubox.cmmn.service.CommonService;
import aero.cubox.core.vo.PaginationVO;
import aero.cubox.door.service.DoorGroupService;
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
@RequestMapping(value = "/door/group/")
public class DoorGroupController {

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

    @Resource(name = "terminalService")
    private TerminalService terminalService;

    @Resource(name = "authService")
    private AuthService authService;

    private int curPageUnit= 10; //한번에 표시할 페이지 번호 개수
    private String initSrchRecPerPage = "10"; //한번에 표시할 페이지 번호 개수

    public int autoOffset(int srchPage, int srchCnt ){
        int off = (srchPage - 1) * srchCnt;
        if(off<0) off = 0;
        return off;
    }

    private static final Logger LOGGER = LoggerFactory.getLogger(DoorGroupController.class);

    /**
     * 출입문 그룹 목록 조회
     *
     * @param model
     * @param commandMap
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/list.do")
    public String showDoorGroupListView(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

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

            List<HashMap> doorGroupList = doorGroupService.getSchDoorGroupList(paramMap);
            int totalCnt = doorGroupService.getDoorGroupListCount(paramMap);

            PaginationVO pageVO = new PaginationVO();
            pageVO.setCurPage(srchPage);
            pageVO.setRecPerPage(srchRecPerPage);
            pageVO.setTotRecord(totalCnt);
            pageVO.setUnitPage(curPageUnit);
            pageVO.calcPageList();

            model.addAttribute("doorGroupList", doorGroupList);
            model.addAttribute("keyword", keyword);
            model.addAttribute("pagination", pageVO);

        } catch (Exception e){
            e.printStackTrace();
            modelAndView.addObject("message", e.getMessage());
        }

        return "cubox/door/group/list";
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
    @RequestMapping(value = "/listAjax.do", method = RequestMethod.POST)
    public ModelAndView listAjax(ModelMap model, @RequestParam Map<String, Object> commandMap, RedirectAttributes redirectAttributes) throws Exception {

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

            List<HashMap> doorGroupList = doorGroupService.getSchDoorGroupList(paramMap);
            int totalCnt = doorGroupService.getDoorGroupListCount(paramMap);

            PaginationVO pageVO = new PaginationVO();
            pageVO.setCurPage(srchPage);
            pageVO.setRecPerPage(srchRecPerPage);
            pageVO.setTotRecord(totalCnt);
            pageVO.setUnitPage(curPageUnit);
            pageVO.calcPageList();

            model.addAttribute("doorGroupList", doorGroupList);
            model.addAttribute("keyword", keyword);
            model.addAttribute("pagination", pageVO);

        } catch (Exception e){
            e.printStackTrace();
            modelAndView.addObject("message", e.getMessage());
        }

        return modelAndView;
    }


    // 스케쥴 출입문 그룹 관리 상세
    @RequestMapping(value = "/detail/{id}", method = RequestMethod.GET)
    public String detail(ModelMap model, @PathVariable int id, HttpServletRequest request) throws Exception {

        HashMap doorGroupDetail = doorGroupService.getDoorGroupDetail(id);

        HashMap param = new HashMap();
        List<HashMap> scheduleList = doorScheduleService.getDoorScheduleList(param);      // 스케쥴 목록

        model.addAttribute("doorGroupDetail", doorGroupDetail);
        model.addAttribute("scheduleList", scheduleList);

        return "cubox/door/group/detail";
    }

    // 스케쥴 출입문 그룹 관리 등록화면
    @RequestMapping(value = "/add.do", method = RequestMethod.GET)
    public String addGroupView(ModelMap model, @RequestParam Map<String, Object> commandMap, RedirectAttributes redirectAttributes) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        HashMap param = new HashMap();
        List<HashMap> scheduleList = doorScheduleService.getDoorScheduleList(param);      // 스케쥴 목록

        model.addAttribute("scheduleList", scheduleList);

        return "cubox/door/group/add";
    }

    // 스케쥴 출입문 그룹 관리 등록
    @ResponseBody
    @RequestMapping(value = "/save.do", method = RequestMethod.POST)
    public ModelAndView saveDoorGroup(ModelMap model, @RequestParam Map<String, Object> commandMap, RedirectAttributes redirectAttributes) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "Y";

        String nm = StringUtil.nvl(commandMap.get("nm"), "");
        String scheduleId = StringUtil.nvl(commandMap.get("scheduleId"), "");
        String doorIds = StringUtil.nvl(commandMap.get("doorIds"), "");

        HashMap param = new HashMap();

        param.put("nm", nm);
        if(scheduleId.length() ==0){
            param.put("doorSchId", null);
        }else{
            param.put("doorSchId", scheduleId);
        }
        param.put("doorIds", doorIds);
        String newDoorId = "";

        try {
             newDoorId = doorGroupService.addDoorGroup(param);
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
    public ModelAndView modify(ModelMap model, @PathVariable String id, HttpServletRequest request, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");

        String resultCode = "Y";

        if (id == null) {
             resultCode = "N";
        } else {
            String nm = StringUtil.nvl(commandMap.get("nm"), "");
            String scheduleId = StringUtil.nvl(commandMap.get("scheduleId"), "");
            String doorIds = StringUtil.nvl(commandMap.get("doorIds"), "");

            HashMap param = new HashMap();

            param.put("id", Integer.parseInt(id));
            param.put("nm", nm);
            param.put("doorSchId", scheduleId);
            param.put("doorIds", doorIds);

            try {
                doorGroupService.updateDoorGroup(param);

            } catch (Exception e) {
                e.getStackTrace();
                resultCode = "N";
            }
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
            doorGroupService.deleteDoorGroup(id);
        } catch (Exception e) {
            e.getStackTrace();
            resultCode = "N";
        }


        model.addAttribute("resultCode", resultCode);

        return modelAndView;
    }


    @RequestMapping(value = "/name/verification.do", method = RequestMethod.GET)
    public ModelAndView getDoorGroupNameValidation(ModelMap model, @RequestParam Map<String, Object> commandMap) throws Exception {

        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        HashMap<String, Object> param = new HashMap<String, Object>();

        param.put("doorGroupNm", commandMap.get("doorGroupNm"));

        int doorGroupNameVerificationCnt = doorGroupService.getDoorGroupNameVerification(param);

        modelAndView.addObject("doorGroupNameVerificationCnt", doorGroupNameVerificationCnt);

        return modelAndView;
    }

    @RequestMapping(value="/excel/download.do", method = RequestMethod.GET)
    public void excelDownloadDoorGroup(ModelMap model, @RequestParam Map<String, Object> commandMap, HttpServletResponse response) throws Exception {

        HashMap<String, Object> paramMap = new HashMap();
        List<HashMap> schDoorGroupList = doorGroupService.getSchDoorGroupList(paramMap);

        ///// Create Excel /////
        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet();
        Row row = null;
        Cell cell = null;
        int rowNum = 0;

        //// Header ////
        final String[] colNames = {"번호", "출입문 그룹명", "출입문 스케쥴명", "출입문 수", "등록일자", "수정일자"};
        // Header size
        final int[] colWidths = {1500, 8000, 6000, 2500, 3500, 3500};
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
        for (int i = 0; i < schDoorGroupList.size(); i++) {
            row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(i + 1);
            row.createCell(1).setCellValue(schDoorGroupList.get(i).get("nm").toString());
            if (schDoorGroupList.get(i).containsKey("door_sch_nm")) {
                row.createCell(2).setCellValue(schDoorGroupList.get(i).get("door_sch_nm").toString());
            }
            row.createCell(3).setCellValue(Integer.parseInt(schDoorGroupList.get(i).get("door_cnt").toString()));
            if (schDoorGroupList.get(i).containsKey("created_at")) {
                row.createCell(4).setCellValue(schDoorGroupList.get(i).get("created_at").toString());
            }
            if (schDoorGroupList.get(i).containsKey("updated_at")) {
                row.createCell(5).setCellValue(schDoorGroupList.get(i).get("updated_at").toString());
            }
        }

        // Date
        SimpleDateFormat fmt = new SimpleDateFormat("yyMMdd-HHmmss");
        Date date = new Date();

        // File name
        String fileNm = "출입문그룹관리목록_" + fmt.format(date) + ".xlsx";
        response.setContentType("ms-vnd/excel");
        response.setHeader("Content-Disposition", "attatchment;filename=" + URLEncoder.encode(fileNm, "UTF-8"));
        wb.write(response.getOutputStream());
    }

}
