<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<jsp:include page="/WEB-INF/jsp/cubox/common/checkPasswd.jsp" flush="false"/>
<script type="text/javascript" src="/js/charts/loader.js"></script>
<script type="text/javascript" src="/js/charts/charts.min.js"></script>
<script type="text/javascript" src="/js/charts/utils.js"></script>
<style>
canvas {
	-moz-user-select: none;
	-webkit-user-select: none;
	-ms-user-select: none;
}
</style>
<script type="text/javascript" src="/js/jquery.simple-calendar.js"></script>

<script type="text/javascript">

	let threadRefresh;

	$(function() {
		// 숫자만 입력가능
		$(".onlyNumber").keyup(function(event) {
			if (!(event.keyCode >=37 && event.keyCode<=40)) {
				let inputVal = $(this).val();
				$(this).val(inputVal.replace(/[^0-9]/gi,''));
			}
		});	
		
		//자동새로고침 증가
		$("#btnRefreshIncrease").click(function() {
			if (parseInt($("#intervalSecond").val()) < 999) {
				$("#intervalSecond").val( parseInt($("#intervalSecond").val())+1);
			}
		});
		
		reload();
	});

	//새로고침
	function reload() {
		//chart01 - 출입이력 현황 임시
		$.ajax({
			type:"GET",
			url:"<c:url value='/main/getMainStatus01.do' />",
			data:{},
			dataType: "json",
			success:function(result) {
				// console.log("getMainStatus01");
				// console.log(result);
				if (result != null && result.mainStatus01 != null) {
					fnEntHistoryChartDraw(result.mainStatus01);
				}
			}
		});

		//chart 02 알람이력 현황
		$.ajax({
			type:"GET",
			url:"<c:url value='/main/getMainStatus02.do' />",
			data:{},
			dataType: "json",
			success:function(result) {
				// var arrStatDt = [];
				// arrStatDt.push(['알람이력 횟수' ]);
				if(result != null && result.mainStatus02 != null) {
					fnAlarmHistoryChartDraw(result.mainStatus02);
					 // for(var i in result.mainStatus02) {
						// var arr = [result.mainStatus02[i].exp_day, parseInt(result.mainStatus02[i].tot_log_cnt)];
						// arrStatDt.push(arr);
						//
					// }

				}
			}
		});

		//log list1
		$.ajax({
			type:"GET",
			url: "<c:url value='/main/entHist'/>",
			data:{},
			dataType: "json",
			success:function(result) {
				fnEntHistSet(result);
			}
		});

		//log list2
		$.ajax({
			type:"GET",
			url: "<c:url value='/main/alarmHist'/>",
			data:{},
			dataType: "json",
			success:function(result) {
				fnAlarmHistSet(result);
			}
		});

	}

	// 출입카드 차트
	// function fnCardTypeChartDraw(data) {
	// 	console.log("fnCardTypeChartDraw");
	// 	console.log(data);
	//
	// 	let ctx = $("#canvas2").get(0).getContext("2d");
	//
	// 	let dataObj = {
	// 		labels : ["공무원증", "신분증", "공무직원증", "일반출입증", "장기공무증", "방문증", "예약방문증", "국회(공무원증)"],
	// 		datasets: [
	// 			{
	// 				data: [20, 2, 5, 40, 5, 10, 8, 10],
	// 				backgroundColor: [
	// 					'#F2F3F6',
	// 					'#9DCEFF',
	// 					'#7a96f1',
	// 					'#2c52c7',
	// 					'#555e7a',
	// 					'#152146',
	// 					'#eedfab',
	// 					'#eeac48',
	// 				],
	// 				borderWidth: 0,
	// 				scaleBeginAtZero: true,
	// 			}
	// 		]
	// 	}
	//
	// 	new Chart("canvas2", {
	// 		type: 'doughnut',
	// 		data: dataObj,
	// 		options: {
	// 			responsive: true,				/*자동크기 조정*/
	// 			maintainAspectRatio : false, 	/*가로세로 비율*/
	// 			elements: {
	// 				line: {
	// 					tension: 0.000001		/*line 곡선 조절*/
	// 				}
	// 			},
	// 			legend: {display: false},
	// 			title: {
	// 				display: false,
	// 				text: '출입카드 유형'
	// 			},
	// 			tooltips: {
	// 				mode: 'index',
	// 				intersect: true
	// 			},
	// 			layout: {
	// 				padding: {
	// 					left: 0,
	// 					right: 0,
	// 					top: 0,
	// 					bottom: 10
	// 				}
	// 			}
	// 		}
	// 	});
	//
	// }

	// 알람이력 차트
	function fnAlarmHistoryChartDraw(data) {
		// console.log("fnAlarmHistoryChartDraw");
		// console.log(data);

		let dtLabel = [],
			data1 = [];

		for (let i in data) {
			dtLabel.push(data[i].alarm_day);
			data1.push(parseInt(data[i].tot_alarm_cnt));
		}

		let chartData = {
			labels: dtLabel, // x축 데이터 라벨
			datasets: [{
				type: 'line',
				label: '알람이력횟수',
				borderColor: '#173d93',		//window.chartColors.blue
				borderWidth: 2,
				fill: true,
				backgroundColor: '#eef9fc',
				pointStyle: 'circle',
				pointRadius: 5,
				pointHoverRadius: 10,
				data: data1
			}]
		};

		let ctx = document.getElementById('canvas2').getContext('2d');
		let myMixedChart = new Chart(ctx, {
			type: 'bar',
			data: chartData,
			options: {
				/* indexAxis: 'y', */
				responsive: true,				/*자동크기 조정*/
				maintainAspectRatio : false, 	/*가로세로 비율*/
				elements: {
					line: {
						tension: 0.000001		/*line 곡선 조절*/
					}
				},
				legend: {
					display: true,
					usePointStyle: true,
					position: 'bottom',
					align : "end",
					labels: {
						fontSize : 11,
						padding : 0,
					}
				},
				title: {
					text: '알람이력현황'
				},
				tooltips: {
					mode: 'index',
					intersect: true
				},
				layout: {
					padding: {
						left: 0,
						right: 0,
						top: 0,
						bottom: 10
					}
				}
			}
		});
	}

	// 출입이력 차트
	function fnEntHistoryChartDraw(data) {
		// console.log("fnEntHistoryChartDraw");
		// console.log(data);

		let dtLabel = [],
			data1 = [],
			data2 = [],
			data3 = [];

		for (let i in data) {
			dtLabel.push(data[i].exp_day);
			data1.push(parseInt(data[i].tot_log_cnt));
			data2.push(parseInt(data[i].fail_log_cnt));
			data3.push(parseInt(data[i].success_log_cnt));
		}

		let color = Chart.helpers.color;
		let chartData = {
			labels: dtLabel, // x축 데이터 라벨
			datasets: [{
				type: 'line',
				label: '출입이력',
				borderColor: '#173d93',		//window.chartColors.blue
				borderWidth: 2,
				pointRadius: 5,
				pointHoverRadius: 10,
				fill: false,
				data: data1
			}, {
				type: 'bar',
				label: '출입성공',
				backgroundColor: color('#1072d2').alpha(0.8).rgbString(),	//window.chartColors.green
				data: data3,
				borderWidth: 2
			}, {
				type: 'bar',
				label: '출입실패',
				backgroundColor: color('#6e7375').alpha(0.8).rgbString(),		//window.chartColors.red
				data: data2,
				borderWidth: 2
			}]

		};

		let ctx = document.getElementById('canvas1').getContext('2d');
		let myMixedChart = new Chart(ctx, {
			type: 'bar',
			data: chartData,
			options: {
				/* indexAxis: 'y', */
				responsive: true,				/*자동크기 조정*/
				maintainAspectRatio : false, 	/*가로세로 비율*/
				elements: {
					line: {
						tension: 0.000001		/*line 곡선 조절*/
					}
				},
				legend: {
					display: true,
					position: 'bottom',
					align : "end",
					labels: {
						fontSize : 11,
						padding : 0,
					}
				},
				title: {
					text: '출입이력현황'
				},
				tooltips: {
					mode: 'index',
					intersect: true
				},
				layout: {
					padding: {
						left: 0,
						right: 0,
						top: 0,
						bottom: 10
					}
				}
			}
		});
		myMixedChart.update();
	}


	function fnEntHistSet (data) {
		// console.log("fnLogInfoListSet");
		// console.log(data);

		if(data == null || data.entHistList == null) {
			$("#entHistListBody").html("<tr><th class='h_35px' colspan='6'>조회 목록이 없습니다.</th></tr>");
		} else {
			var histList = data.entHistList;
			var str = "";
			for(var i in histList) {
				str += "<tr>";
				str += "<td>"+histList[i].id+"</td>";
				str += "<td>"+histList[i].evtDtStr+"</td>";
				str += "<td>"+histList[i].doorNm+"</td>";
				str += "<td>"+histList[i].empNm+"</td>";
				str += "<td>"+histList[i].cardStateTypNm+"</td>";
				str += "<td>"+histList[i].entEvtTypNm+"</td>";
				str += "</tr>";
			}
			$("#entHistListBody").html(str);
		}
	}

    function fnAlarmHistSet (data) {

        if( data == null || data.alarmHistList == null) {
            $("#alarmHistListBody").html("<tr><th class='h_35px' colspan='4'>조회 목록이 없습니다.</th></tr>");
        } else {
            var histList = data.alarmHistList;
            var str = "";
            for(var i in histList) {
                str += "<tr>";
                str += "<td>"+histList[i].evtDtStr+"</td>";
                str += "<td>"+histList[i].doorAlarmTypNm+"</td>";
                str += "<td>"+histList[i].buildingNm+"</td>";
                str += "<td>"+histList[i].doorNm+"</td>";
                str += "</tr>";
            }
            $("#alarmHistListBody").html(str);
        }
    }


	function autoRefresh(value) {
		var reloadYn = $("#reloadYn");
		if(value == "N"){
			reloadYn.val("Y");
			var sec = parseInt($("#intervalSecond").val());
			alert(sec +  "초마다 자동 새로고침이 시작됩니다.");
			$("#btnReloadYn").val("Y");
			$("#btnReloadYn").html("중지");
			threadRefresh = setInterval(function(){this.reload()}, sec * 1000);
			reload();
		} else {
			reloadYn.val("N");
			alert("자동 새로고침이 중지되었습니다.");
			$("#btnReloadYn").val("N");
			$("#btnReloadYn").html("시작");
			clearInterval(threadRefresh);
		}
	}

	function fnGateLog(){
		f = document.frmSearch;
		f.action = "report/entHist/list.do";
		f.submit();
	}

	function fnAlarmLog() {
		f = document.frmSearch;
		f.action = 'report/alarmHist/list.do';
		f.submit();
	}

	function fnBoardList(bbsId){
		f = document.frmSearch;
		f.action = "/boardInfo/"+pad(bbsId,20)+"/list.do";
		f.submit();
	}

	function fnBoardDetail(nttId, bbsId){
		var f = document.frmSearch;

		$("input:hidden[id=hidNttId]").val(nttId);
		f.action = "/boardInfo/"+pad(bbsId,20)+"/detail.do";
		f.submit();
	}

	function pad(n, width) {
		  n = n + '';
		  return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
	}

</script>
<div class="main_a" style="padding-top: 0px; margin: 15px 0;">
	<div class="st_box">
		<div class="icon">
			<img src="/img/main/m_icon03.png" alt="" />
		</div>
		<div class="tx1">출입이력</div>
		<div class="tx2">
			<em id="visitReqCnt"></em><a href="/report/entHist/list.do">[바로가기]</a>
		</div>
	</div>
	<div class="st_box">
		<div class="icon">
			<img src="/img/main/m_icon05.png" alt="" />
		</div>
		<div class="tx1">스케쥴 관리</div>
		<div class="tx2">
			<em id="dayCnt"></em><a href="/door/schedule/list.do">[바로가기]</a>
		</div>
	</div>
	<div class="st_box">
		<div class="icon">
			<img src="/img/main/m_icon02.png" alt="" />
		</div>
		<div class="tx1">단말기 관리</div>
		<div class="tx2">
			<em id="obsCnt"> </em><a href="/terminal/list.do">[바로가기]</a>
		</div>
	</div>
	<div class="st_box">
		<div class="icon">
			<img src="/img/main/m_icon01.png" alt="" />
		</div>
		<div class="tx1">사용자 관리</div>
		<div class="tx2">
			<em id="inmateCnt"></em><a href="/user/list.do">[바로가기]</a>
		</div>
	</div>
	<div class="w_200px"></div>
	<form id="frmSearch" name="frmSearch" method="post" onsubmit="return false;">
	<input type="hidden" id="hidNttId" name="hidNttId">
		<input type="hidden" id="reloadYn" name="reloadYn" value='<c:out value="${reloadYn}"/>'>
		<div class="w_180px">
			<div class="comm_search mr_5">
	            <input type="text" class="w_90px input_com onlyNumber" id="intervalSecond" name="intervalSecond" value="5" maxlength="3"  placeholder="">
	            <div class="plus_btn" id="btnRefreshIncrease"></div>
	        </div>
	        <button type="button" id="btnReloadYn" value='N' onclick="autoRefresh(this.value)" class="btn_middle color_gray">시작</button>
		</div>
	</form>

</div>

<div class="main_b" style="padding-top: 20px;">
	<div class="main_left" style="width: 49%;">
		<div class="inbox7" style="width: 100%; height: 360px;">
			<div class="title">
				출입이력 현황
			</div>
			<div>
				<div style="height: 280px; margin-left: 10px;">
					<canvas id="canvas1"></canvas>
				</div>
			</div>
		</div>
		<div class="inbox7" style="width: 100%; height: 360px; margin-top:40px;">
			<div class="title">
				알람이력 현황
			</div>
			<div>
				<div style="height: 280px; margin-left: 10px;">
					<canvas id="canvas2"></canvas>
				</div>
			</div>
		</div>
	</div>

	<div class="main-right" style="width: 49%;">
		<jsp:include page="/WEB-INF/jsp/cubox/common/main_ent_hist.jsp" flush="false"/>
		<jsp:include page="/WEB-INF/jsp/cubox/common/main_alarm_hist.jsp" flush="false"/>
	</div>


</div>
