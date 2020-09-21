# This file is used by Rack-based servers to start the application.

# Prometheus monitoring
require_relative 'config/environment'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

# Unicorn self-process killer
require 'unicorn/worker_killer'

# Max memory size (RSS) per worker
use Unicorn::WorkerKiller::Oom, (192*(1024**2)), (256*(1024**2))

require ::File.expand_path('config/environment', __dir__)
run Rails.application
