<%--
  Created by IntelliJ IDEA.
  User: USER
  Date: 2022-09-23
  Time: 오후 3:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
    .color_disabled {
        background-color: #eee !important;
        opacity: 1;
    }
</style>

<script type="text/javascript">
    $(function() {
        $(".title_tx").html("스케쥴 출입문 그룹 관리 - 상세");

        modalPopup("doorEditPopup", "출입문 선택", 900, 600);

        // 출입문 그룹 명 유효성 체크
        $("#gpNm").focusout(function() {
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
        }
        fnUpdateGroupAjax();
    }

    // 수정 취소
    function fnCancel() {
        $(".title_tx").html("스케쥴 출입문 그룹 관리 - 상세");
        $("#btnboxDetail").css("display", "block");
        $("#btnboxEdit").css("display", "none");
        $("#btnEdit").css("display", "none");

        $("#detailForm").load(location.href + ' #detailForm');
        $("[name=detail]").attr("disabled", true).addClass("color_disabled");
    }

    // 수정 버튼
    function fnEditMode() {
        if (confirm("해당 출입문 그룹을 수정하시겠습니까?")) {
            $(".title_tx").html("스케쥴 출입문 그룹 관리 - 수정");
            $("#btnEdit").css("display", "block");
            $("#btnboxDetail").css("display", "none");
            $("#btnboxEdit").css("display", "block");
            $("[name=detail]").attr("disabled", false).removeClass("color_disabled");
        } else {
            return;
        }
    }

    // 삭제 버튼
    function fnDelete() {
        // 연결된 출입문 존재 시
        if ($("#gpDoorIds").val() != "") {
            alert("연결된 출입문을 모두 해제한 후 삭제하세요.");
            return;
        }

        if (!confirm("삭제하시겠습니까?")) {
            return;
        }

        let id= $("#doorGroupId").val(); // example - doorgroup id

        $.ajax({
            type: "post",
            url: "/door/group/delete/" + id,
            dataType: 'json',
            success: function (data, status) {
                if (data.resultCode == "Y") {
                    alert("삭제가 완료되었습니다.");
                    location.href = "/door/group/list.do";
                } else {
                    alert("삭제 중 오류가 발생하였습니다.");
                }
            }
        });
    }

    // popup open (공통)
    function openPopup(popupNm) {
        $("#" + popupNm).PopupWindow("open");
        if (popupNm === "doorEditPopup") {
            fnGetDoorListAjax("Group"); //출입문 목록
        }
    }

    // popup close (공통)
    function closePopup(popupNm) {
        setDoors("Group");
        $("#" + popupNm).PopupWindow("close");
    }


    /////////////////  출입문 그룹 수정 ajax - start  /////////////////////

    function fnUpdateGroupAjax() {

        let id = $("#doorGroupId").val();
        let gpNm = $("#gpNm").val();
        let scheduleId = $("#gpSchedule").val();
        let doorIds = $("#gpDoorIds").val();
        let url = "<c:url value='/door/group/modify/${doorGroupDetail.id}' />";

        $.ajax({
            type: "POST",
            url: url,
            data:{
                nm: gpNm,
                scheduleId: scheduleId,
                doorIds: doorIds // 1, 1/2  2개 이상일 경우 "/" 으로 구분자 추가
            },
            dataType: "json",
            success: function (result) {
                console.log(result.resultCode);

                if( result.resultCode == "Y" ) {
                    alert("수정이 완료되었습니다.");
                    window.location.href = '/door/group/detail/' + id;
                } else {
                    alert("수정에 실패하였습니다.");
                }
            }
        });
    }

    /////////////////  출입문 그룹 수정 ajax - end  /////////////////////


</script>
<form id="detailForm" name="detailForm" method="post" enctype="multipart/form-data">
    <div class="tb_01_box">
        <table class="tb_write_02 tb_write_p1 box">
            <colgroup>
                <col style="width:10%">
                <col style="width:90%">
            </colgroup>
            <tbody id="tdGroupDetail">
            <input type="hidden" id="doorGroupId" value="${doorGroupDetail.id}">
            <input type="hidden" id="gpDoorIds" value="${doorGroupDetail.door_ids}">
            <tr>
                <th>출입문 그룹 명</th>
                <td>
                    <input type="text" id="gpNm" name="detail" maxlength="35" value="${doorGroupDetail.nm}"
                           class="input_com w_600px color_disabled" onkeyup="charCheck(this)" onkeydown="charCheck(this)" disabled>
                </td>
            </tr>
<%--            <tr>--%>
<%--                <th>출입문 스케쥴</th>--%>
<%--                <td>--%>
<%--                    <input type="text" id="gpSchedule" name="detail" maxlength="50" value="3${doorGroupDetail.nm}" class="input_com w_600px" disabled>--%>
<%--                </td>--%>
<%--            </tr>--%>
            <tr>
                <th>출입문 스케쥴</th>
                <td>
                    <select id="gpSchedule" name="detail" class="form-control input_com w_600px color_disabled" style="padding-left:10px;" disabled>
                        <option value="" selected>선택</option>
                        <c:forEach items="${scheduleList}" var="schedule" varStatus="status">
                            <option value='<c:out value="${schedule.id}"/>'<c:if test="${schedule.id eq doorGroupDetail.door_sch_id}"> selected</c:if>>
                                <c:out value="${schedule.door_sch_nm}"/>
                            </option>
                        </c:forEach>
                    </select>
                </td>
            </tr>
            <tr>
                <th>출입문 수</th>
                <td>
                    <input type="text" id="gpDoorCnt" name="gpDoorCnt" maxlength="50" value="${doorGroupDetail.door_cnt}" class="input_com w_600px" disabled>
                </td>
            </tr>
            <tr>
            <tr>
                <th>출입문</th>
                <td style="display: flex;">
                    <%--  TODO: testarea에 공백 해결  --%>
                    <textarea id="gpDoorNms" name="gpDoorNms" rows="10" cols="33" class="w_600px color_disabled" style="border-color: #ccc; border-radius: 2px;
                              font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled><c:set var="nm" value="${fn:split(doorGroupDetail.door_nms,'/')}" /><c:forEach items="${nm}" var="dName" varStatus="varStatus">
${dName}</c:forEach></textarea>
                    <div class="ml_10" style="position: relative;">
                        <button id="btnEdit" type="button" class="btn_small color_basic" style="position: absolute; bottom: 0; width: 60px; display: none;" onclick="openPopup('doorEditPopup')">선택</button>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</form>

<div class="right_btn mt_20" id="btnboxDetail">
    <button class="btn_middle color_basic" onclick="location='/door/group/list.do'">목록</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnEditMode();">수정</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnDelete();">삭제</button>
</div>
<div class="right_btn mt_20" id="btnboxEdit" style="display:none;">
<button class="btn_middle ml_5 color_basic" onclick="location='/door/group/list.do'" id="listBtn">목록</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnSave();" id="saveBtn">저장</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnCancel();" id="cancelBtn">취소</button>
</div>
