<%--
  Created by IntelliJ IDEA.
  User: USER
  Date: 2022-09-23
  Time: 오후 3:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/jsp/cubox/common/checkPasswd.jsp" flush="false"/>
<jsp:include page="/WEB-INF/jsp/cubox/common/doorPickPopup.jsp" flush="false"/>

<style>
    .title_box {
        margin-top: 10px;
        margin-bottom: 20px;
    }
    .box {
        border: 1px solid #ccc;
        /*width: 715px;*/
    }
    #tdGroupDetail tr th {
        text-align: center;
    }
    thead {
        position: sticky;
        top: 0;
    }
    #doorSelected tr th {
        text-align: center;
    }
    .color_disabled {
        background-color: #eee !important;
        opacity: 1;
    }
</style>

<script type="text/javascript">

    $(function () {

        $(".title_tx").html("스케쥴 출입문 그룹 관리 - 등록");
        modalPopup("doorEditPopup", "출입문 선택", 900, 600);

        $("#gpNm").focus();
        $("#listBtn").hide();

        // 출입문 그룹 명 유효성 체크
        $("#gpNm").focusout(function () {
            // TODO : 출입문 그룹 명 유효성 체크 (ajax)
        });

    });

    // 출입문 저장, 등록
    function fnSave() {
        // 입력값 유효성 체크
        if (fnIsEmpty($("#gpNm").val())) {
            alert("출입문 그룹 명을 입력해주세요.");
            $("#gpNm").focus();
            return;
        } else if (fnIsEmpty($("#gpSchedule").val())) {
            alert("출입문 스케쥴을 선택해주세요.");
            $("#gpSchedule").focus();
            return;
        }

        if (confirm("저장하시겠습니까?")) {
            fnSaveGroupAjax();
        } else {
            return;
        }
    }

    // popup open (공통)
    function openPopup(popupNm) {
        $("#" + popupNm).PopupWindow("open");
        fnGetDoorListAjax("Group"); //출입문 목록
    }

    // popup close (공통)
    function closePopup(popupNm) {
        setDoors("Group");
        $("#" + popupNm).PopupWindow("close");
    }


    /////////////////  출입문 그룹 저장 ajax - start  /////////////////////

    function fnSaveGroupAjax() {
        let gpNm = $("#gpNm").val();
        let scheduleId = $("#gpSchedule").val();
        let doorIds = $("#gpDoorIds").val();

        $.ajax({
            type: "POST",
            url: "<c:url value='/door/group/save.do' />",
            data:{
                nm: gpNm,
                scheduleId: scheduleId,
                doorIds: doorIds // 1, 1/2  2개 이상일 경우 "/" 으로 구분자 추가
            },
            dataType: "json",
            success: function (result) {
                // console.log(result);

                if (result.resultCode === "Y" && result.newDoorId !== "") {
                    alert("저장되었습니다.");
                    window.location.href = '/door/group/detail/' + result.newDoorId;
                } else {
                    alert("등록에 실패하였습니다.");
                }

            }
        });
    }

    /////////////////  출입문 그룹 저장 ajax - end  /////////////////////

</script>
<form id="detailForm" name="detailForm" method="post" enctype="multipart/form-data">
    <div class="tb_01_box">
        <table class="tb_write_02 tb_write_p1 box">
            <colgroup>
                <col style="width:10%">
                <col style="width:90%">
            </colgroup>

            <tbody id="tdGroupDetail">
            <input type="hidden" id="gpDoorIds" value="">
            <tr>
                <th>스캐쥴 출입문 그룹 명</th>
                <td>
                    <input type="text" id="gpNm" name="gpNm" maxlength="35" value="" class="input_com w_600px" onkeyup="charCheck(this)" onkeydown="charCheck(this)">
                </td>
            </tr>
            <tr>
                <th>출입문 스케쥴</th>
                <td>
                    <select id="gpSchedule" name="gpSchedule" class="form-control input_com w_600px" style="padding-left:10px;">
                        <option value="">선택</option>
                        <c:forEach items="${scheduleList}" var="schedule" varStatus="status">
                            <option value='<c:out value="${schedule.id}"/>'><c:out value="${schedule.door_sch_nm}"/></option>
                        </c:forEach>
                    </select>
                </td>
            </tr>
            <tr>
                <th>출입문 수</th>
                <td>
                    <input type="number" id="gpDoorCnt" name="gpDoorCnt" maxlength="50" value="0" class="input_com w_600px" disabled>&ensp;
                </td>
            </tr>
            <tr>
            <tr>
                <th>출입문</th>
                <td style="display: flex;">
                    <textarea id="gpDoorNms" name="gpDoorNms" rows="10" cols="33" class="w_600px color_disabled" style="border-color: #ccc; border-radius: 2px; font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled></textarea>
                    <div class="ml_10" style="position: relative;">
                        <button type="button" class="btn_small color_basic" style="position: absolute; bottom: 0; width: 60px;" onclick="openPopup('doorEditPopup')">선택</button>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</form>

<div class="right_btn mt_20">
    <button class="btn_middle ml_5 color_basic" onclick="location='/door/group/list.do'" id="listBtn">목록</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnSave();" id="saveBtn">저장</button>
    <button class="btn_middle ml_5 color_basic" onclick="location='/door/group/list.do'" id="cancelBtn" >취소</button>
</div>


