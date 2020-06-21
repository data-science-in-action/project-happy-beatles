use "C:\Users\86130\Desktop\深圳合成控制数据.dta" //获得深圳合成控制数据
tsset 序号 日期

**合成控制法-----------------------------------
synth 发病率 lngdp ln人口密度 累计确诊 老年人口比例 武汉迁出比例 距离武汉距离倒数 发病率(1922), trunit(7)trperiod(1924) xperiod(1919(1)1923) figure nested keep(scm_synth)

**计算处理效应--------------------
use scm_synth
gen effect = _Y_treated - _Y_synthetic
label variable _time "date"
label variable effect "发病率"
line effect _time, xline(1923, lp(dash)) yline(0, lp(dash))

**安慰剂检验--------------------
use "C:\Users\86130\Desktop\深圳合成控制数据.dta" //获得深圳合成控制数据
tsset 序号 日期

forval i=1/28{
qui synth 发病率 lngdp ln人口密度 累计确诊 老年人口比例 武汉迁出比例 距离武汉距离倒数 发病率(1922), ///
xperiod(1919(1)1923) trunit(`i')trperiod(1924) keep(synth_`i', replace)
}             //对所有28个地区分别进行SCM(把28个地区分别作为政策影响组)

forval i=1/28{
use synth_`i', clear
rename _time date
gen tr_effect_`i' = _Y_treated - _Y_synthetic
keep date tr_effect_`i'
drop if missing(date)
save synth_`i', replace
}              //得到SCM的政策效应

use synth_1, clear
forval i=2/28{
qui merge 1:1 date using synth_`i', nogenerate
}       //把所有28个政策效应合并起来

local lp
forval i=1/28 {
  local lp `lp' line tr_effect_`i' date, lcolor(gs12) ||
  twoway `lp' || line tr_effect_7 date, ///
   lcolor(orange) legend(off) xline(1923, lpattern(dash))
}        //画图
