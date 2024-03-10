import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payment_tool/constants.dart';
import 'package:payment_tool/functions.dart';
import 'package:payment_tool/qrAdminPanel.dart';

class TextSummayCard extends StatelessWidget {
  final dynamic datastream;

  const TextSummayCard({Key? key, required this.datastream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: StreamBuilder(
          stream: datastream,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const CircularProgressIndicator();
            }

            var datos = getTotalFacturacionPorDia(snapshot.data.docs);

            var numPagos = datos['totalDePagosEnFecha']['NumberOfPayments'];
            var totalOfDaysInMonthPassed = datos['Days']['DaysOfMonth'];
            var averagePaymentsPerDay = numPagos / totalOfDaysInMonthPassed;

            var totalFacturadoMes = datos['totalPorDia']['Valor'];
            var mediaImportePagos = totalFacturadoMes / numPagos;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Resumen mensual',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Card(
                    color: AppColors.IconColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: StyleConstants.border,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Divider(
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          ListTile(
                            trailing: const Icon(Icons.monetization_on),
                            title: Text(
                              'Facturación Total: ${totalFacturadoMes}€',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListTile(
                            title: Text(
                              'Pago medio por cliente:$mediaImportePagos €',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200),
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          ListTile(
                            trailing: const Icon(
                                Icons.format_list_numbered_rtl_outlined),
                            title: Text(
                              'Total nº de pagos: $numPagos',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Media nº pagos diarios:  $averagePaymentsPerDay',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200),
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LineChartTotalFact extends StatefulWidget {
  var datastream;
  var lastNRegistros;

  LineChartTotalFact({
    super.key,
    required this.datastream,
    required this.lastNRegistros,
    Color? gradientColor1,
    Color? gradientColor2,
    Color? gradientColor3,
    Color? indicatorStrokeColor,
  })  : gradientColor1 = gradientColor1 ?? Colors.white,
        gradientColor2 =
            gradientColor2 ?? const Color.fromRGBO(114, 142, 235, 1),
        gradientColor3 = gradientColor3 ?? AppColors.IconColor,
        indicatorStrokeColor = indicatorStrokeColor ?? Colors.black;

  final Color gradientColor1;
  final Color gradientColor2;
  final Color gradientColor3;
  final Color indicatorStrokeColor;

  @override
  State<LineChartTotalFact> createState() => _LineChartTotalFactState();
}

class _LineChartTotalFactState extends State<LineChartTotalFact> {
  Widget bottomTitleWidgets(
      double value, fechas, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.pink,
      fontFamily: 'Digital',
      fontSize: 12 * chartWidth / 500,
    );
    if (value < 0 || value >= fechas.length) {
      return Container();
    }

    // Formatear la fecha según sea necesario, aquí un ejemplo simple
    DateTime fecha = fechas[value.toInt()];
    String text =
        DateFormat('d/M').format(fecha); // Usar el formato que prefieras

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Facturación QR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Card(
              color: AppColors.IconColor2,
              shape: RoundedRectangleBorder(
                borderRadius: StyleConstants.border, // Esquinas redondeadas
              ),
              child: AspectRatio(
                aspectRatio: 2.6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 30.0,
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return StreamBuilder(
                      stream: widget.datastream,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data!.docs != null &&
                            snapshot.data!.docs.isNotEmpty) {
                          // Aquí se convierten los datos del snapshot en allSpots

                          List<FlSpot> allSpots = getLineChartData(
                                  snapshot.data.docs, widget.lastNRegistros)
                              .map((data) => data['punto'] as FlSpot)
                              .toSet()
                              .toList();

                          List<dynamic> allDates = getLineChartData(
                                  snapshot.data.docs, widget.lastNRegistros)
                              .map((data) => data['fecha'])
                              .toSet()
                              .toList();

                          var spotsLen = allSpots.length;
                          List<int> showingTooltipOnSpots = [];

                          int lenSpot = 0;
                          while (lenSpot < spotsLen) {
                            var spot = allSpots[lenSpot];
                            if (spot.y > 0) {
                              showingTooltipOnSpots.add(lenSpot);
                            }
                            lenSpot += 1;
                          }

                          final lineBarsData = [
                            LineChartBarData(
                              isStrokeCapRound: true,
                              isStepLineChart: false,
                              showingIndicators: showingTooltipOnSpots,
                              spots: allSpots,
                              isCurved: true,
                              barWidth: 4,
                              shadow: const Shadow(
                                blurRadius: 8,
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    widget.gradientColor1.withOpacity(0.4),
                                    widget.gradientColor2.withOpacity(0.4),
                                    widget.gradientColor3.withOpacity(0.4),
                                  ],
                                ),
                              ),
                              dotData: const FlDotData(show: false),
                              gradient: LinearGradient(
                                colors: [
                                  widget.gradientColor1,
                                  widget.gradientColor2,
                                  widget.gradientColor3,
                                ],
                                stops: const [0.1, 0.4, 0.9],
                              ),
                            ),
                          ];

                          final tooltipsOnBar = lineBarsData[0];

                          return LineChart(
                            LineChartData(
                              showingTooltipIndicators:
                                  showingTooltipOnSpots.map((index) {
                                return ShowingTooltipIndicators([
                                  LineBarSpot(
                                    tooltipsOnBar,
                                    lineBarsData.indexOf(tooltipsOnBar),
                                    tooltipsOnBar.spots[index],
                                  ),
                                ]);
                              }).toList(),
                              lineTouchData: LineTouchData(
                                enabled: true,
                                handleBuiltInTouches: false,
                                touchCallback: (FlTouchEvent event,
                                    LineTouchResponse? response) {
                                  if (response == null ||
                                      response.lineBarSpots == null) {
                                    return;
                                  }
                                  if (event is FlTapUpEvent) {
                                    final spotIndex =
                                        response.lineBarSpots!.first.spotIndex;
                                    setState(() {
                                      if (showingTooltipOnSpots
                                          .contains(spotIndex)) {
                                        showingTooltipOnSpots.remove(spotIndex);
                                      } else {
                                        showingTooltipOnSpots.add(spotIndex);
                                      }
                                    });
                                  }
                                },
                                mouseCursorResolver: (FlTouchEvent event,
                                    LineTouchResponse? response) {
                                  if (response == null ||
                                      response.lineBarSpots == null) {
                                    return SystemMouseCursors.basic;
                                  }
                                  return SystemMouseCursors.click;
                                },
                                getTouchedSpotIndicator:
                                    (LineChartBarData barData,
                                        List<int> spotIndexes) {
                                  return spotIndexes.map((index) {
                                    return TouchedSpotIndicatorData(
                                      const FlLine(
                                        color: Colors.pink,
                                      ),
                                      FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) =>
                                                FlDotCirclePainter(
                                          radius: 3,
                                          color: lerpGradient(
                                            barData.gradient!.colors,
                                            barData.gradient!.stops!,
                                            percent / 100,
                                          ),
                                          strokeWidth: 2,
                                          strokeColor:
                                              widget.indicatorStrokeColor,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.pink,
                                  tooltipRoundedRadius: 3,
                                  getTooltipItems:
                                      (List<LineBarSpot> lineBarsSpot) {
                                    return lineBarsSpot.map((lineBarSpot) {
                                      return LineTooltipItem(
                                        lineBarSpot.y.toString(),
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              lineBarsData: lineBarsData,
                              minY: 0,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  axisNameWidget:
                                      Container(), // Vacío para no mostrar nada
                                  axisNameSize:
                                      0, // Tamaño cero para el nombre del eje
                                  sideTitles: const SideTitles(
                                    showTitles:
                                        false, // No mostrar títulos en los ejes superiores
                                    reservedSize:
                                        0, // Tamaño reservado cero para los títulos de los ejes
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  axisNameWidget:
                                      Container(), // Vacío para no mostrar nada
                                  axisNameSize:
                                      0, // Tamaño cero para el nombre del eje
                                  sideTitles: const SideTitles(
                                    showTitles:
                                        false, // No mostrar títulos en los ejes superiores
                                    reservedSize:
                                        0, // Tamaño reservado cero para los títulos de los ejes
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  axisNameWidget:
                                      Container(), // Vacío para no mostrar nada
                                  axisNameSize:
                                      0, // Tamaño cero para el nombre del eje
                                  sideTitles: SideTitles(
                                    showTitles:
                                        true, // Habilitar la visualización de títulos en el eje inferior
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      int index = value.toInt();
                                      if (index >= 0 &&
                                          index < allDates.length) {
                                        var fecha = allDates[index];
                                        String formattedDate = DateFormat('d/M')
                                            .format(fecha); // Formato de fecha
                                        return Transform.rotate(
                                          angle: -45 *
                                              3.1415927 /
                                              180, // Rotar -45 grados (en radianes)
                                          child: Text(
                                            formattedDate,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 10),
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                    reservedSize:
                                        45, // Aumentar el espacio reservado para los títulos
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  axisNameWidget:
                                      Container(), // Vacío para no mostrar nada
                                  axisNameSize:
                                      0, // Tamaño cero para el nombre del eje
                                  sideTitles: const SideTitles(
                                    showTitles:
                                        false, // No mostrar títulos en los ejes superiores
                                    reservedSize:
                                        0, // Tamaño reservado cero para los títulos de los ejes
                                  ),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: Colors.white10,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'Aún no hay datos.',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      },
                    );
                  }),
                ),
              )),
        ),
      ],
    );
  }
}

class LineChartCount extends StatefulWidget {
  var datastream;
  var lastNRegistros;

  LineChartCount({
    super.key,
    required this.datastream,
    required this.lastNRegistros,
    Color? gradientColor1,
    Color? gradientColor2,
    Color? gradientColor3,
    Color? indicatorStrokeColor,
  })  : gradientColor1 = gradientColor1 ?? AppColors.IconColor,
        gradientColor2 =
            gradientColor2 ?? const Color.fromARGB(255, 123, 150, 240),
        gradientColor3 = gradientColor3 ?? Colors.white,
        indicatorStrokeColor = indicatorStrokeColor ?? Colors.black;

  final Color gradientColor1;
  final Color gradientColor2;
  final Color gradientColor3;
  final Color indicatorStrokeColor;

  @override
  _LineChartCountState createState() => _LineChartCountState();
}

class _LineChartCountState extends State<LineChartCount> {
  Widget bottomTitleWidgets(
      double value, fechas, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.pink,
      fontFamily: 'Digital',
      fontSize: 18 * chartWidth / 500,
    );
    if (value < 0 || value >= fechas.length) {
      return Container();
    }

    // Formatear la fecha según sea necesario, aquí un ejemplo simple
    DateTime fecha = fechas[value.toInt()];
    String text =
        DateFormat('d/M').format(fecha); // Usar el formato que prefieras

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Nº de pagos QR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Card(
              color: AppColors.IconColor2,
              shape: RoundedRectangleBorder(
                borderRadius: StyleConstants.border, // Esquinas redondeadas
              ),
              child: AspectRatio(
                aspectRatio: 4.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 30.0,
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return StreamBuilder(
                      stream: widget.datastream,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Center(
                                  child: Text(
                                      'Error: ${snapshot.error}'))); // Mostrar mensaje de error
                        }

                        if (snapshot.connectionState == ConnectionState.done ||
                            snapshot.connectionState ==
                                ConnectionState.active) {
                          if (snapshot.data!.docs.isNotEmpty) {
                            // Aquí se convierten los datos del snapshot en allSpots

                            List<FlSpot> allSpots = getLineChartData(
                                    snapshot.data.docs, widget.lastNRegistros)
                                .map((data) => data['punto'] as FlSpot)
                                .toList();

                            List<dynamic> allDates = getLineChartData(
                                    snapshot.data.docs, widget.lastNRegistros)
                                .map((data) => data['fecha'])
                                .toList();

                            var spotsLen = allSpots.length;
                            List<int> showingTooltipOnSpots = [];
                            int lenSpot = 0;
                            while (lenSpot < spotsLen) {
                              var spot = allSpots[lenSpot];
                              if (spot.y > 0) {
                                showingTooltipOnSpots.add(lenSpot);
                              }
                              lenSpot +=
                                  1; // Incrementa lenSpot después de usarlo para acceder a la lista
                            }

                            final lineBarsData = [
                              LineChartBarData(
                                showingIndicators: showingTooltipOnSpots,
                                spots: allSpots,
                                isCurved: true,
                                barWidth: 4,
                                shadow: const Shadow(
                                  blurRadius: 8,
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.gradientColor1.withOpacity(0.4),
                                      widget.gradientColor2.withOpacity(0.4),
                                      widget.gradientColor3.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                                dotData: const FlDotData(show: false),
                                gradient: LinearGradient(
                                  colors: [
                                    widget.gradientColor1,
                                    widget.gradientColor2,
                                    widget.gradientColor3,
                                  ],
                                  stops: const [0.1, 0.4, 0.9],
                                ),
                              ),
                            ];

                            final tooltipsOnBar = lineBarsData[0];

                            return LineChart(
                              LineChartData(
                                showingTooltipIndicators:
                                    showingTooltipOnSpots.map((index) {
                                  return ShowingTooltipIndicators([
                                    LineBarSpot(
                                      tooltipsOnBar,
                                      lineBarsData.indexOf(tooltipsOnBar),
                                      tooltipsOnBar.spots[index],
                                    ),
                                  ]);
                                }).toList(),
                                lineTouchData: LineTouchData(
                                  enabled: true,
                                  handleBuiltInTouches: false,
                                  touchCallback: (FlTouchEvent event,
                                      LineTouchResponse? response) {
                                    if (response == null ||
                                        response.lineBarSpots == null) {
                                      return;
                                    }
                                    if (event is FlTapUpEvent) {
                                      final spotIndex = response
                                          .lineBarSpots!.first.spotIndex;
                                      setState(() {
                                        if (showingTooltipOnSpots
                                            .contains(spotIndex)) {
                                          showingTooltipOnSpots
                                              .remove(spotIndex);
                                        } else {
                                          showingTooltipOnSpots.add(spotIndex);
                                        }
                                      });
                                    }
                                  },
                                  mouseCursorResolver: (FlTouchEvent event,
                                      LineTouchResponse? response) {
                                    if (response == null ||
                                        response.lineBarSpots == null) {
                                      return SystemMouseCursors.basic;
                                    }
                                    return SystemMouseCursors.click;
                                  },
                                  getTouchedSpotIndicator:
                                      (LineChartBarData barData,
                                          List<int> spotIndexes) {
                                    return spotIndexes.map((index) {
                                      return TouchedSpotIndicatorData(
                                        const FlLine(
                                          color: Colors.pink,
                                        ),
                                        FlDotData(
                                          show: true,
                                          getDotPainter:
                                              (spot, percent, barData, index) =>
                                                  FlDotCirclePainter(
                                            radius: 8,
                                            color: lerpGradient(
                                              barData.gradient!.colors,
                                              barData.gradient!.stops!,
                                              percent / 100,
                                            ),
                                            strokeWidth: 2,
                                            strokeColor:
                                                widget.indicatorStrokeColor,
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  touchTooltipData: LineTouchTooltipData(
                                    tooltipBgColor: Colors.pink,
                                    tooltipRoundedRadius: 6,
                                    getTooltipItems:
                                        (List<LineBarSpot> lineBarsSpot) {
                                      return lineBarsSpot.map((lineBarSpot) {
                                        return LineTooltipItem(
                                          lineBarSpot.y.toString(),
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                lineBarsData: lineBarsData,
                                minY: 0,
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    axisNameWidget:
                                        Container(), // Vacío para no mostrar nada
                                    axisNameSize:
                                        0, // Tamaño cero para el nombre del eje
                                    sideTitles: const SideTitles(
                                      showTitles:
                                          false, // No mostrar títulos en los ejes superiores
                                      reservedSize:
                                          0, // Tamaño reservado cero para los títulos de los ejes
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    axisNameWidget:
                                        Container(), // Vacío para no mostrar nada
                                    axisNameSize:
                                        0, // Tamaño cero para el nombre del eje
                                    sideTitles: SideTitles(
                                      showTitles:
                                          true, // Habilitar la visualización de títulos en el eje inferior
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        int index = value.toInt();
                                        if (index >= 0 &&
                                            index < allDates.length) {
                                          var fecha = allDates[index];
                                          String formattedDate =
                                              DateFormat('d/M').format(
                                                  fecha); // Formato de fecha
                                          return Transform.rotate(
                                            angle: -45 *
                                                3.1415927 /
                                                180, // Rotar -45 grados (en radianes)
                                            child: Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            ),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                      reservedSize:
                                          45, // Aumentar el espacio reservado para los títulos
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    axisNameWidget:
                                        Container(), // Vacío para no mostrar nada
                                    axisNameSize:
                                        0, // Tamaño cero para el nombre del eje
                                    sideTitles: const SideTitles(
                                      showTitles:
                                          false, // No mostrar títulos en los ejes superiores
                                      reservedSize:
                                          0, // Tamaño reservado cero para los títulos de los ejes
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    axisNameWidget:
                                        Container(), // Vacío para no mostrar nada
                                    axisNameSize:
                                        0, // Tamaño cero para el nombre del eje
                                    sideTitles: const SideTitles(
                                      showTitles:
                                          false, // No mostrar títulos en los ejes superiores
                                      reservedSize:
                                          0, // Tamaño reservado cero para los títulos de los ejes
                                    ),
                                  ),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: Colors.white10,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'Aún no hay datos.',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                        } else {
                          return const Center(
                            child: Text('Error'),
                          );
                        }
                      },
                    );
                  }),
                ),
              )),
        ),
      ],
    );
  }
}
