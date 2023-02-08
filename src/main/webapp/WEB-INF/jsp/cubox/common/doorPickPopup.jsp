<%@ page import="java.util.ResourceBundle" %><%--
  Created by IntelliJ IDEA.
  User: USER
  Date: 2022-10-07
  Time: 오후 3:58
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    ResourceBundle resource = ResourceBundle.getBundle("egovframework.property.globals");

    String CRUD_TYPE  = resource.getString("Globals.door.crud.type");
%>

<style>
    #doorSelected tr th {
        text-align: center;
    }
</style>

<script type="text/javascript">
let crudType ="<%=CRUD_TYPE%>";

$(function () {
    // 출입문 추가
    $(".add_door").click(function () {
        let nodeSel = $("a.nodeSel").html();
        let nodeSelId = $("a.nodeSel").find("span").attr("id");
        let doorSelected = $("#doorSelected").children();
        // 이미 같은 출입문 있을 경우 return
        for (let i = 0; i < doorSelected.length; i++) {
            let doorPath = doorSelected.eq(i).children().last().html();
            if (doorPath == nodeSel) {
                alert("이미 선택된 출입문입니다.");
                return;
            }
        }
        if (nodeSelId != null || nodeSelId != undefined) {
            let tag = "<tr><td><input type='checkbox' id='" + nodeSelId + "' name='chkDoorConf'></td><td>" + nodeSel + "</td></tr>";
            $("#doorSelected").append(tag);
        }

    });

    // 출입문 삭제
    $(".delete_door").click(function () {
        let ckd = $("input[name=chkDoorConf]:checked").length;
        if (ckd === 0) {
            alert("제거할 항목이 없습니다.");
        } else {
            for (let i = ckd - 1; i > -1; i--) {
                $("input[name=chkDoorConf]:checked").eq(i).closest("tr").remove();
            }
        }

        if ($("#chkDoorConfAll").prop("checked")) {
            $("#chkDoorConfAll").prop("checked", false);
        }
    });

    $("#chkDoorConfAll").click(function () {
        if ($("#chkDoorConfAll").prop("checked")) {
            $("input[name=chkDoorConf]").prop("checked", true);
        } else {
            $("input[name=chkDoorConf]").prop("checked", false);
        }
    });

});

function userCheck() {
    if ($("#chkDoorConfAll").prop("checked")) {
        $("#chkDoorConfAll").prop("checked", false);
    }
}


// 출입문선택 반영
function setDoors(type) {
    // console.log("setDoors type = " + type);

    let doorGpIds = "";
    let doorGpHtml = [];
    $("input[name=chkDoorConf]").each(function (i) {
        let ids = $(this).attr("id");
        let html = $(this).closest("tr").children().eq(1).find("span").html();
        if (i == 0) {
            doorGpIds += ids;
        } else if (i > 0) {
            doorGpIds += ("/" + ids);
        }
        doorGpHtml.push(html);
    });

    if (type === "Group") {                 // 그룹관리
        $("#gpDoorIds").val(doorGpIds);
        $("#gpDoorNms").val(doorGpHtml.join("\r\n"));
        $("#gpDoorCnt").val($("input[name=chkDoorConf]").length);
    } else if (type === "AlarmGroup") {     // 알람그룹
        $("#doorIds").val(doorGpIds);
        $("#alDoorNms").val(doorGpHtml.join("\r\n"));
        $("#alDoorCnt").val($("input[name=chkDoorConf]").length);   // 출입문 수
    }
}


    /////////////////  출입문 목록 ajax - start  /////////////////////

    function fnGetDoorListAjax(type) {

        $.ajax({
            type : "GET",
            data : { },
            dataType : "json",
            url : "<c:url value='/door/list.do' />",
            success : function(result) {
                // console.log(result);

                createTree(crudType, false, result, $("#treeDiv"));
                $("#doorSelected").empty();
                let doorList;
                if (type === "Group" && $("#gpDoorIds").val() != "") { // 수정일 떄
                    doorList = $("#gpDoorIds").val().split("/");
                } else if (type === "AlarmGroup" && $("#doorIds").val() !== "") {
                    doorList = $("#doorIds").val().split("/");
                }

                $.each(doorList, function(i, door) {
                    $("span[id=" + door + "]").parent().toggleClass("node nodeSel");
                    $(".add_door").click();
                    $("span[id=" + door + "]").parent().toggleClass("nodeSel node");
                });
            }
        });
    }
    /////////////////  출입문 목록 ajax - end  /////////////////////

</script>

<%--  출입문 선택 modal  --%>
<div id="doorEditPopup" class="example_content" style="display: none;">
    <div class="popup_box box_w3">
        <div style="width:45%;">
            <div class="com_box"
                 style="border: 1px solid black; background-color: white; overflow: auto; height: 400px; padding: 2px 10px;">
                <div id="treeDiv"></div>
            </div>
        </div>

        <%--  화살표 이동  --%>
        <div style="height: 400px; display: flex; justify-content: center; flex-wrap: wrap; flex-direction: column; align-items: center;">
            <div class="btn_box" style="margin:5px 0;">
                <img src="/img/ar_r.png" alt="" class="add_door"/>
            </div>
            <div class="btn_box" style="margin:5px 0;">
                <img src="/img/ar_l.png" alt="" class="delete_door"/>
            </div>
        </div>
        <%--  end of 화살표 이동  --%>

        <%--  테이블  --%>
        <div style="width:45%;">
            <div class="com_box" style="border: 1px solid black; background-color: white; overflow: auto; height: 400px;">
                <table class="tb_list tb_write_02 tb_write_p1">
                    <colgroup>
                        <col style="width:10%">
                        <col style="width:90%">
                    </colgroup>
                    <thead>
                        <tr>
                            <th><input type="checkbox" id="chkDoorConfAll"></th>
                            <th>출입문</th>
                        </tr>
                    </thead>
                    <tbody id="doorSelected"></tbody>
                </table>
            </div>
        </div>
        <%--  end of 테이블  --%>

        <div class="c_btnbox center mt_30">
            <div style="display: inline-block;">
                <button type="button" class="comm_btn mr_20" onclick="closePopup('doorEditPopup');">확인</button>
            </div>
        </div>
    </div>
</div>
<%--  end of 출입문 선택 modal  --%>
