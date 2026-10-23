const assert=require('node:assert/strict'),d=require('./core.js');
const a=d.audience(7,3);assert(a.length>0);assert(a.every(u=>u.age>=14&&u.idle>=7&&u.active>=3&&u.consent&&u.touch>=7));
assert.equal(d.audience(999,3).length,0);assert.throws(()=>d.audience(-1,3));assert.throws(()=>d.audience(2.5,3));
const t={name:'test',text:'欢迎回到游戏',time:'2099-01-01T12:00'};d.validate(a,t);
for(const list of [null,[]])assert.throws(()=>d.validate(list,t));
for(const patch of [{name:''},{text:''},{text:'a'.repeat(81)},{text:'免费奖励'},{time:'2000-01-01'},{time:''}])assert.throws(()=>d.validate(a,{...t,...patch}));
assert.equal(d.act('草稿','submit','运营'),'待审核');assert.equal(d.act('待审核','approve','审核人'),'待执行');assert.equal(d.act('待执行','run','运营'),'已完成');
assert.throws(()=>d.act('已完成','run','运营'));assert.throws(()=>d.act('待审核','run','运营'));assert.throws(()=>d.act('待审核','approve','运营'));assert.throws(()=>d.act('草稿','submit','审核人'));assert.throws(()=>d.act('已取消','run','运营'));
assert.equal(d.act('待审核','reject','审核人'),'已驳回');assert.equal(d.act('待执行','cancel','运营'),'已取消');console.log('Core validation and state-transition assertions passed');
