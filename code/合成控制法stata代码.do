use 合成控制法数据.dta, clear   //获得SCM数据
tsset 序号 date 

**合成控制法-----------------------------------
 synth 发病率 lnGDP ln人口密度 累计确诊人数 发病率(1985) 发病率(1991),
 trunit(29)trperiod(1993) xperiod(1980(1)1992) figure nested keep(scm_synth))

**计算处理效应--------------------
use scm_synth
gen effect = _Y_treated - _Y_synthetic
label variable _time "date"
label variable effect "发病率"
line effect _time, xline(1993, lp(dash)) yline(0, lp(dash))

**安慰剂检验--------------------
forval i=1/29{
qui synth 发病率 lnGDP ln人口密度 累计确诊人数 发病率(1985) 发病率(1991), ///
xperiod(1980(1)1992) trunit(`i') trperiod(1993) keep(synth_`i', replace)
}             //对所有29个地区分别进行SCM(把29个地区分别作为政策影响组)

forval i=1/29{
use synth_`i', clear
rename _time date
gen tr_effect_`i' = _Y_treated - _Y_synthetic
keep date tr_effect_`i'
drop if missing(date)
save synth_`i', replace
}              //得到SCM的政策效应

use synth_1, clear
forval i=2/29{
qui merge 1:1 years using synth_`i', nogenerate
}       //把所有29个政策效应合并起来

local lp
forval i=1/29 {
  local lp `lp' line tr_effect_`i' years, lcolor(gs12) ||
  twoway `lp' || line tr_effect_3 years, ///
   lcolor(orange) legend(off) xline(1989, lpattern(dash))
}        //画图
