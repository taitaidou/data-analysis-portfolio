(function(root){
'use strict';
const users=Array.from({length:100},(_,i)=>({id:'DEMO-'+String(i+1).padStart(3,'0'),age:10+i,active:1+i%12,idle:i%24,consent:i%5!==0,touch:i%13}));
function audience(idle,active){if(!Number.isInteger(idle)||idle<0||!Number.isInteger(active)||active<1)throw Error('条件必须为整数，未活跃天数≥0，活跃天数≥1');return users.filter(u=>u.age>=14&&u.active>=active&&u.idle>=idle&&u.consent&&u.touch>=7);}
function validate(a,t,now=Date.now()){if(!a)throw Error('请重新预览人群');if(!a.length)throw Error('人群为0，不能提交');if(!t.name.trim()||!t.text.trim())throw Error('任务名称和文案不能为空');if(Array.from(t.text).length>80)throw Error('文案不得超过80字符');if(/现金|免费|奖励|红包/.test(t.text))throw Error('文案包含未批准的权益，请修改');if(!Number.isFinite(Date.parse(t.time))||Date.parse(t.time)<=now)throw Error('请选择未来的计划时间');}
function act(state,action,role){const rules={submit:['运营',['草稿','已驳回','已取消'],'待审核'],approve:['审核人',['待审核'],'待执行'],reject:['审核人',['待审核'],'已驳回'],run:['运营',['待执行'],'已完成'],cancel:['运营',['草稿','待审核','待执行','已驳回'],'已取消']};const r=rules[action];if(!r||role!==r[0]||!r[1].includes(state))throw Error('当前角色或任务状态不允许该操作');return r[2];}
const api={users,audience,validate,act};if(typeof module!=='undefined')module.exports=api;else root.Demo=api;
})(typeof window!=='undefined'?window:globalThis);
