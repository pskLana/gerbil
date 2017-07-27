<%@page import="org.aksw.gerbil.web.ExperimentTaskStateHelper"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>

<head>
<link rel="stylesheet"
	href="/gerbil/webjars/bootstrap/3.2.0/css/bootstrap.min.css">
<title>Overview</title>
<script type="text/javascript"
	src="/gerbil/webjars/jquery/2.1.1/jquery.min.js"></script>
<script type="text/javascript"
	src="/gerbil/webjars/bootstrap/3.2.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="http://d3js.org/d3.v3.min.js"></script>
<script type="text/javascript"
	src="/gerbil/webResources/js/gerbil.color.js"></script>
<script type="text/javascript"
	src="/gerbil/webResources/js/RadarChart.js"></script>
<script type="text/javascript"
	src="/gerbil/webResources/js/script_radar_overview.js"></script>
<link rel="icon" type="image/png"
	href="/gerbil/webResources/gerbilicon_transparent.png">
</head>
<style>
table {
	table-layout: fixed;
}

.table>thead>tr>th {
	vertical-align: middle !important;
	height: 280px;
	width: 20px !important;
}

.rotated_cell div {
	display: block;
	transform: rotate(270deg);
	-moz-transform: rotate(270deg);
	-ms-transform: rotate(270deg);
	-o-transform: rotate(270deg);
	-webkit-transform: rotate(270deg);
	width: 250px;
	position: relative;
	top: -10;
	left: -100;
}

.col-md-12 {
	padding: 5px 0px;
}

.chartDiv { /*position: absolute;*/
	top: 50px;
	left: 100px;
	vertical-align: center;
	text-align: center;
}

.chartBody {
	overflow: hidden;
	margin: 0;
	font-size: 14px;
	font-family: "Helvetica Neue", Helvetica;
}
</style>

<body>
	<div class="container">
		<!-- mappings to URLs in back-end controller -->
		<c:url var="experimentoverview" value="/experimentoverview" />
		<c:url var="matchings" value="/matchings" />
		<c:url var="exptypes" value="/exptypes" />

		<%@include file="navbar.jsp"%>
		<h1>GERBIL Experiment Overview</h1>
		<div class="form-horizontal">
			<div class="col-md-12">
				<div class="control-group">
					<label class="col-md-4 control-label">Experiment Type</label>
					<div id="expTypes" class="col-md-8"></div>
				</div>
			</div>

			<div class="col-md-12" style="visibility:hidden;">
				<div class="control-group">
					<label class="col-md-4 control-label">Matching</label>
					<div id="matching" class="col-md-8"></div>
				</div>
			</div>
			<div class="col-md-12">
				<div class="control-group">
					<label class="col-md-4 control-label"></label>
					<div class="col-md-8">
						<button id="show" type="button" class="btn btn-default">Show
							table!</button>
					</div>
				</div>
			</div>
			<div class="col-md-12">
				<h2>Leaderboards</h2>
				<p>The tables will show the current leader at the specific dataset</p>
			</div>
			<!-- <div class="container-fluid"> -->
			<div class="col-md-12">
				<div id="resultsChartBody" class="chartBody">
					<div id="resultsChart" class="chartDiv"></div>
				</div>
			</div>
		</div>
	</div>
	<div class="container-fluid" id="resultsTable">
<!-- 		<table id="resultsTable" class="table table-hover table-condensed"> -->
<!-- 			<thead></thead> -->
<!-- 			<tbody></tbody> -->
<!-- 		</table> -->
	</div>
	<div class="container" style="visibility:hidden;">
		<div class="form-horizontal">
			<div class="col-md-12">
				<h2>Annotator &ndash; Dataset feature correlations</h2>
				<p>The table as well as the diagram contain the pearson
					correlations between the annotators and the dataset features. Note
					that the diagram only shows the absolute values of the correlation.
					For the correlation type, you should take a look at the table.</p>
			</div>
			<!-- <div class="container-fluid"> -->
			<div class="col-md-12">
				<div id="correlationsChartBody" class="chartBody">
					<div id="correlationsChart" class="chartDiv"></div>
				</div>
			</div>
		</div>
	</div>
	<div class="container-fluid" style="visibility:hidden;">
		<table id="correlationsTable"
			class="table table-hover table-condensed">
			<thead></thead>
			<tbody></tbody>
		</table>
	</div>

	<script type="text/javascript">
		function loadMatchings() {
			$
					.getJSON(
							'${matchings}',
							{
								experimentType : $('#expTypes input:checked')
										.val(),
								ajax : 'false'
							},
							function(data) {
								var htmlMatchings = "";
								for (var i = 0; i < data.Matching.length; i++) {
									htmlMatchings += "<label class=\"btn btn-primary\" >";
									htmlMatchings += " <input class=\"toggle\" type=\"radio\" name=\"matchingType\" id=\"" + data.Matching[i].name + "\" value=\"" + data.Matching[i].name + "\" >"
											+ data.Matching[i].label;
									htmlMatchings += "</label>";
								}
								$('#matching').html(htmlMatchings);
								$('#matching input')[0].checked = true;
								$('#matching label')
										.each(
												function(index) {
													for (var i = 0; i < data.Matching.length; i++) {
														if (data.Matching[i].name == $(
																this).find(
																'input').val()) {
															$(this)
																	.attr(
																			'data-toggle',
																			'tooltip')
																	.attr(
																			'data-placement',
																			'top')
																	.attr(
																			'title',
																			data.Matching[i].description);
														}
													}
												});

								$('[data-toggle="tooltip"]').tooltip();
							});
		};

		function loadExperimentTypes() {
			$
					.getJSON(
							'${exptypes}',
							{
								ajax : 'false'
							},
							function(data) {
								console.log(data);
								var htmlExperimentTypes = "";
								for (var i = 0; i < data.ExperimentType.length; i++) {
									htmlExperimentTypes += "<label class=\"btn btn-primary\" >";
									htmlExperimentTypes += " <input class=\"toggle\" type=\"radio\" name=\"experimentType\" id=\"" + data.ExperimentType[i].name + "\" value=\"" + data.ExperimentType[i].name + "\" >"
											+ data.ExperimentType[i].label;
									htmlExperimentTypes += "</label>";
								}
								$('#expTypes').html(htmlExperimentTypes);
								$('#expTypes input')[0].checked = true;
								// Add the listener for loading the matchings
								$("#expTypes input").change(loadMatchings);
								loadMatchings();

								$('#expTypes label')
										.each(
												function(index) {
													for (var i = 0; i < data.ExperimentType.length; i++) {
														if (data.ExperimentType[i].name == $(
																this).find(
																'input').val()) {
															$(this)
																	.attr(
																			'data-toggle',
																			'tooltip')
																	.attr(
																			'data-placement',
																			'top')
																	.attr(
																			'title',
																			data.ExperimentType[i].description);
														}
													}
												});

								$('[data-toggle="tooltip"]').tooltip();

							});
		};

		function loadTables() {
			$.getJSON('${experimentoverview}', {
				experimentType : $('#expTypes input:checked').val(),
				ajax : 'false'
			}, function(data, experimentType) {
				for(var i = 0; i < data.datasets.length; i++) {
					var tableData = data.datasets[i];
					showTable(tableData, "resultsTable", experimentType);
				}
			}).fail(function() {
				console.log("error loading data for table");
			});
		};

		function showTable(tableData, tableElementId, experimentType) {
			//http://stackoverflow.com/questions/1051061/convert-json-array-to-an-html-table-in-jquery
			var tbl_body = "";
		    var measure = "F1 measure";
		    if(experimentType==="SWC2"){
		    	measure = "Area Under Curve (AUC)"
		    }
			var tbl_hd = "<tr><th>AnnotatorName</th><th>" + measure + "</th></tr>";
			var tbl="<h3>Dataset: "+tableData.datasetName+"</h3><table id=\"" + tableData.datasetName + "\" class=\"table table-hover table-condensed\">";
			tbl+=tbl_hd;
			var leader = tableData.leader;
			for(var i = 0; i < leader.length; i++) {
				//TODO add elements from tableData
				var tbl_row = "<tr>";
				tbl_row+="<td>"+leader[i].annotatorName+"</td>";
				tbl_row+="<td>"+leader[i].value+"</td>";
				tbl_row+="</tr>";
				tbl_body+=tbl_row;
			};
			tbl+=tbl_body;
			tbl+="</table>";
			$("#" + tableElementId).html(tbl);
		}

		function drawSpiderDiagram(tableData, chartElementId) {
			//draw spider chart
			var chartData = [];
			//Legend titles  ['Smartphone','Tablet'];
			var LegendOptions = [];
			$.each(tableData, function(i) {
				//iterate over rows
				if (i > 0) {
					var annotatorResults = [];
					$.each(this, function(k, v) {
						if (k == 0) {
							//annotator
							LegendOptions.push(v);
						} else {
							//results like {axis:"Email",value:0.71},
							var tmp = {};
							tmp.axis = tableData[0][k];
							if (v == "n.a." || v.indexOf("error") > -1) {
								tmp.value = 0;
							} else {
								// if the number is negative make it poositive
								if (v.indexOf("-") > -1) {
									v = v.replace("-", "+");
								}
								tmp.value = v;
							}
							annotatorResults.push(tmp);
						}
					});
					chartData.push(annotatorResults);
				}
			});
			//[[{axis:"Email",value:0.71},{axis:"aa",value:0}],[{axis:"Email",value:0.71},{axis:"aa",value:0.1},]];
			console.log("start drawing into " + chartElementId);
			drawChart(chartData, LegendOptions, chartElementId);
			// add the svg namespace
			//$('#' + chartElementId + ' svg').attr("xmlns:svg",
			//		"http://www.w3.org/2000/svg").attr("xmlns",
			//		"http://www.w3.org/2000/svg");
		}

		$(document).ready(function() {
			//++++++++++++
			//creating the radioboxes
			//++++++++++++
			loadExperimentTypes();

			$("#show").click(function(e) {
				loadTables();
			});
		});
	</script>
</body>
