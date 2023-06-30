import { Controller } from "stimulus"
import { Chart } from "chart.js"

export default class extends Controller {
  static targets = ['genderChart', 'stemChart', 'careerChart']

  static values = {
    genderLabels: Array,
    gender: Array,
    stemLabels: Array,
    stem: Array,
    careerLabels: Array,
    career: Array,
  }

  connect() {
    this.plotGenderGraph()
    this.plotStemChart()
    this.plotCareerChart()
  }

  plotGenderGraph() {
    this.plotGraph(this.genderChartTarget, this.genderLabelsValue, this.genderValue)
  }

  plotStemChart() {
    this.plotGraph(this.stemChartTarget, this.stemLabelsValue, this.stemValue)
  }

  plotCareerChart() {
    this.plotGraph(this.careerChartTarget, this.careerLabelsValue, this.careerValue)
  }

  plotGraph(element, labels, data) {
    new Chart(element, {
      type: "bar",
      data: {
        labels: labels,
        datasets: [{
          fill: true,
          backgroundColor: "rgba(50, 83, 168)",
          borderColor: window.theme.primary,
          data: data
        }]
      },
      options: {
        maintainAspectRatio: false,
        legend: {
          display: false
        },
        tooltips: {
          intersect: false
        },
        hover: {
          intersect: true
        },
        plugins: {
          filler: {
            propagate: false
          }
        },
        scales: {
          xAxes: [{
            reverse: true,
            gridLines: {
              color: "rgba(0,0,0,0.05)"
            }
          }],
          yAxes: [{
            ticks: {
              stepSize: 500
            },
            display: true,
            borderDash: [5, 5],
            gridLines: {
              color: "rgba(0,0,0,0)",
              fontColor: "#fff"
            }
          }]
        }
      }
    })
  }
}
