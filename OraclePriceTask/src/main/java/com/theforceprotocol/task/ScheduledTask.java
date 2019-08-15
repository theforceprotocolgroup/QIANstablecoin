package com.theforceprotocol.task;

import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.text.SimpleDateFormat;
import java.util.Date;

@Slf4j
@Component
@EnableScheduling
public class ScheduledTask {

    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
    @Scheduled(initialDelay=1000, fixedRate = 5*60*1000) // 通过在方法上加@Scheduled注解，表明该方法是一个调度任务,10min, 与配置文件中的livetime相对应
    public void Oracle() {
        log.info("当前时间是 {}", dateFormat.format(new Date()));
        try {
            PriceFeedService.RunAll();
        } catch (Exception ex) {
            log.error("Oracle Ex:" + ex.getMessage());
        }
    }
}
