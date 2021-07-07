// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let hooks = {}
hooks.temperature_chart = {
    mounted() {
        var ctx = this.el.getContext('2d');

        var temperature_chart = new Chart(ctx, {
            // The type of chart we want to create
            type: 'bar',
            // The data for our dataset
            data: {
                labels: ['24', '23', '22', '21',
                         '20', '19', '18', '17',
                         '16', '15', '14', '13',
                         '12', '11', '10', '9',
                         '8', '7', '6', '5',
                         '4', '3', '2', '1'
                        ],
                datasets: [{
                    label: 'Avg Temperature °C (Last 24 hrs)',
                    backgroundColor: 'rgb(34, 208, 178)',
                    borderColor: 'rgb(200, 200, 200)'
                }]
            },
            // Configuration options go here
            options: {}
        })

        this.handleEvent("temperature_points", ({temperature_points}) => {
            temperature_chart.data.datasets[0].data = temperature_points
            temperature_chart.update()
        })
    }
}

hooks.humidity_chart = {
    mounted() {
        var ctx = this.el.getContext('2d');

        var humidity_chart = new Chart(ctx, {
            // The type of chart we want to create
            type: 'bar',
            // The data for our dataset
            data: {
                labels: ['24', '23', '22', '21',
                         '20', '19', '18', '17',
                         '16', '15', '14', '13',
                         '12', '11', '10', '9',
                         '8', '7', '6', '5',
                         '4', '3', '2', '1'
                        ],
                datasets: [{
                    label: 'Avg Humidity % (Last 24 hrs)',
                    backgroundColor: 'rgb(57, 154, 218)',
                    borderColor: 'rgb(200, 200, 200)'
                }]
            },
            // Configuration options go here
            options: {}
        });

        this.handleEvent("humidity_points", ({humidity_points}) => {
            humidity_chart.data.datasets[0].data = humidity_points
            humidity_chart.update()
        })
    }
}

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
