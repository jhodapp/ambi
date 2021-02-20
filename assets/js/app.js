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
                labels: ['0s', '5s', '10s', '15s',
                         '20s', '25s', '30s', '35s',
                         '40s', '45s', '50s', '55s',
                         '60s', '65s', '70s', '75s',
                         '80s', '85s', '90s', '95s',
                         '100s', '105s', '110s', '115s',
                         '120s'
                        ],
                datasets: [{
                    label: 'Temperature °C',
                    backgroundColor: 'rgb(34, 208, 178)',
                    borderColor: 'rgb(34, 208, 178)'
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
            type: 'line',
            // The data for our dataset
            data: {
                labels: ['0s', '5s', '10s', '15s',
                            '20s', '25s', '30s', '35s',
                            '40s', '45s', '50s', '55s',
                            '60s', '65s', '70s', '75s',
                            '80s', '85s', '90s', '95s',
                            '100s', '105s', '110s', '115s',
                            '120s'
                        ],
                datasets: [{
                    label: 'Humidity %',
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
