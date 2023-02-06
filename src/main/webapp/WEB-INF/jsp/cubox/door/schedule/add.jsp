<%--
  Created by IntelliJ IDEA.
  User: USER
  Date: 2022-09-01
  Time: 오후 3:57
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/jsp/cubox/common/checkPasswd.jsp" flush="false"/>
<jsp:include page="/WEB-INF/jsp/cubox/common/doorGroupPickPopup.jsp" flush="false"/>
<jsp:include page="/WEB-INF/jsp/cubox/common/doorPickPopup.jsp" flush="false"/>


<style>
    .title_box {
        margin-top: 10px;
        margin-bottom: 20px;
    }
    .box {
        border: 1px solid #ccc;
    }
    #tdScheduleAdd tr th {
        text-align: center;
    }
    thead {
        position: sticky;
        top: 0;
    }
    .color_disabled {
        background-color: #eee !important;
        opacity: 1;
    }
</style>

<script type="text/javascript">
    $(function() {
        $(".title_tx").html("출입문 스케쥴 - 등록");
        modalPopup("doorGroupPickPopup", "출입문 그룹 선택", 910, 550);
        modalPopup("doorEditPopup", "출입문 선택", 900, 600);
    });

    // 출입문 스케줄 등록 저장
    function fnAdd() {
        // 입력값 유효성 체크
        if (fnIsEmpty($("#schNm").val())) {
            alert ("출입문 스케쥴 명을 입력하세요.");
            $("#schNm").focus(); return;
        }
        if (confirm("출입문 스케쥴을 저장하시겠습니까?")) {
            fnSaveScheduleAjax();
        } else {
            return;
        }
    }

    // popup open
    function openPopup(popupNm) {
        $("#" + popupNm).PopupWindow("open");
        if (popupNm === "doorGroupPickPopup") {
            fnGetDoorGroupListAjax();
        } else if (popupNm === "doorEditPopup") {
            fnGetDoorListAjax("Schedule");
        }
    }

    // popup close
    function closePopup(popupNm) {
        $("#" + popupNm).PopupWindow("close");
        $("input[name='chkGroup']:checked").attr("checked", false);
        $("input[name='chkGroupConf']:checked").attr("checked", false);
        totalCheck();
        userCheck();
    }


    /////////////////  출입문 알람 그룹 명 중복체크 ajax - start  /////////////////////

    function fnVerifyName() {
        let nm = $("#schNm").val();

        $.ajax({
            type: "GET",
            url: '<c:url value="/door/schedule/name/verification.do" />',
            dataType: "json",
            data: { nm: nm },
            success: function(result) {
                console.log(result);
                if (result.doorScheduleNameVerificationCnt != 0) {
                    alert("이미 존재하는 출입문 스케쥴 명입니다.");
                    $("#schNm").val("");
                    $("#schNm").focus();
                    $("#verifyInfo").css("display", "none");
                    $("#verifyInfo").attr("stat", "false");
                } else {
                    // 사용가능한 이름
                    // $("#verifyInfo").css("display", "block");
                    $("#verifyInfo").attr("stat", "true");
                }
            }
        });
    }

    /////////////////  출입문 알람 그룹 명 중복체크 ajax - start  /////////////////////


    /////////////////  출입문 스케쥴 저장 ajax - start  /////////////////////

    function fnSaveScheduleAjax() {
        let doorSchNm = $("#schNm").val();
        let useYn = $("#schUseYn").val();
        let doorIds = $("#doorIds").val();
        let url = "<c:url value='/door/schedule/save.do'/>";

        $.ajax({
            type : "POST",
            data : {
                nm: doorSchNm
                ,useYn: useYn
                ,doorGroupIds: doorIds
                // ,doorIds: doorIds
            },
            dataType : "json",
            url : url,
            success : function(result) {
                console.log(result);
                if (result.resultCode === "Y" && result.newScheduleId !== "") {
                    alert("등록이 완료되었습니다.");
                    window.location.href = '/door/schedule/detail/' + result.newScheduleId;
                } else {
                    alert("등록에 실패하였습니다.");
                }
            }
        });
    }
    /////////////////  출입문 스케쥴 저장 ajax - end  /////////////////////

</script>

<form id="addForm" name="addForm" method="post" enctype="multipart/form-data">
    <div class="tb_01_box">
        <table class="tb_write_02 tb_write_p1 box">
            <colgroup>
                <col style="width:10%">
                <col style="width:90%">
            </colgroup>
            <tbody id="tdScheduleAdd">
                <input type="hidden" id="scheduleId" value="${doorScheduleDetail.id}">
                <input type="hidden" id="doorIds" value="">
                <tr>
                    <th>출입문 스케쥴 명</th>
                    <td>
                        <input type="text" id="schNm" name="schNm" maxlength="35" size="50" value=''
                               class="w_600px input_com" onkeyup="charCheck(this)" onkeydown="charCheck(this)">
                        <div class="ml_10" style="display: none; position: relative; left: 600px;">
                            <button type="button" class="btn_small color_basic" onclick="fnVerifyName()" style="width:60px; position:absolute; bottom:0; display:block;">중복확인</button>
                            <div id="verifyInfo" stat="false" style="display:none; position: relative; font-size: smaller; margin: auto 70px; color: blue;">* 사용가능한 출입문 스케쥴 명</div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th>사용여부</th>
                    <td>
                        <select id="schUseYn" name="schUseYn" class="form-control w_200px" style="padding-left:10px;">
                            <option value="" name="selected">선택</option>
                            <option value="Y">사용</option>
                            <option value="N">미사용</option>
                        </select>
                    </td>
                </tr>
<%--                <tr>--%>
<%--                    <th>출입문 그룹</th>--%>
<%--                    <td style="display: flex;">--%>
<%--                        <textarea id="doorGroup" name="doorGroup" rows="10" cols="33" class="w_600px color_disabled" style="border-color: #ccc; border-radius: 2px;--%>
<%--                                    font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled></textarea>--%>
<%--                        <div class="ml_10" style="position:relative;">--%>
<%--                            <button type="button" class="btn_small color_basic" onclick="openPopup('doorGroupPickPopup')" style="width:60px; position:absolute; bottom:0;">선택</button>--%>
<%--                        </div>--%>
<%--                    </td>--%>
<%--                </tr>--%>
                <tr style="display:none;">
                    <th>출입문</th>
                    <td style="display: flex;">
                        <textarea id="schDoorNms" name="schDoorNms" rows="10" cols="33" class="w_600px color_disabled" style="border-color: #ccc; border-radius: 2px;
                                  font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled>
                        </textarea>
                            <div class="ml_10" style="position: relative;">
                                <button id="btnEdit" type="button" class="btn_small color_basic" style="width:60px; position:absolute; bottom:0;" onclick="openPopup('doorEditPopup')">선택</button>
                            </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</form>

<div class="right_btn mt_20">
    <button class="btn_middle color_basic" onclick="fnAdd();">저장</button>
    <button class="btn_middle ml_5 color_basic" onclick="location='/door/schedule/list.do'">취소</button>
</div>

