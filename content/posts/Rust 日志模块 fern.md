+++
title = 'Rust 日志模块 Fern'
date = '2025-11-13 10:59:17'
lastmodified = ''
categories = []
tags = []
draft = false
summary = 'Fern 使用记录'
+++


# 同时输出到文件和终端

```
use chrono::Local;
use fern::Dispatch;
use anyhow::Result;
use log::{LevelFilter, debug, error, info, warn};


fn setup_logger() -> Result<(), fern::InitError> {
    let info_log = fern::log_file("info.log")?;
    let error_log = fern::log_file("error.log")?;

    let fmt_time =
        |out: fern::FormatCallback, message: &std::fmt::Arguments, record: &log::Record| {
            out.finish(format_args!(
                "[{}][{}] {}",
                Local::now().format("%Y-%m-%d %H:%M:%S"),
                record.level(),
                message
            ))
        };

    // Info 文件: Debug + Info
    let info_dispatch = Dispatch::new()
        .level(LevelFilter::Debug) // 粗过滤
        .filter(|metadata| metadata.level() <= log::Level::Info) // 精过滤
        .format(fmt_time)
        .chain(info_log);

    // Error 文件: Warn + Error
    let error_dispatch = Dispatch::new()
        .level(LevelFilter::Warn) // 只允许 Warn 及以上
        .format(fmt_time)
        .chain(error_log);

    // 控制台输出: Debug 以上
    let stdout_dispatch = Dispatch::new()
        .level(LevelFilter::Debug)
        .format(fmt_time)
        .chain(std::io::stdout());

    // 全局合并
    Dispatch::new()
        .chain(info_dispatch)
        .chain(error_dispatch)
        .chain(stdout_dispatch)
        .apply()?;

    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    setup_logger()?;
    debug!("this is debug message");
    info!("this is info message");
    warn!("this is warn message");
    error!("this is error message");
    Ok(())
}
```

