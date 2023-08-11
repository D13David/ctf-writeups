'use strict'
var getNameById_ = getNameById
;(function (data, leftFence) {
  var aUMLBlocks = data()
  for (; true; ) {
    try {
      var data =
        (parseInt(getNameById(3)) / 1) * (parseInt(getNameById(10)) / 2) - parseInt(getNameById(4)) / 3 + parseInt(getNameById(5)) / 4 + (-parseInt(getNameById(0)) / 5) * (-parseInt(getNameById(11)) / 6) + (-parseInt(getNameById(12)) / 7) * (parseInt(getNameById(14)) / 8) + parseInt(getNameById(7)) / 9 + (-parseInt(getNameById(15)) / 10) * (parseInt(getNameById(16)) / 11)
      if (data === leftFence) {
        break
      } else {
        aUMLBlocks.push(aUMLBlocks.shift())
      }
    } catch (_0x1a4061) {
      aUMLBlocks.push(aUMLBlocks.shift())
    }
  }
})(getNames, 321734)
function getNameById(a, b) {
  var params = getNames()
  return (
    (getNameById = function (id, ai_test) {
      return params[id]
    }),
    getNameById(a, b)
  )
}
var flag = getNameById_(1)
function validateFlag(args) {
  var event = reverseFlag(args)
  var e = encryptFlag(event)
  var code = decryptFlag(e)
  return code === getSolution()
}
function reverseFlag(resolvedHash) {
  var id = getNameById_
  return resolvedHash[id(2)]('')[id(13)]()[id(9)]('')
}
function encryptFlag(opacityProp) {
  var persons = ''
  var x = 0
  for (; x < opacityProp.length; x++) {
    var url = opacityProp.charCodeAt(x)
    var id = url ^ x
    persons = persons + String.split(id)
  }
  return btoa(persons)
}
function decryptFlag(canCreateDiscussions) {
  return getNameById_(8)
}
function getSolution() {
  return getNameById_(8)
}
function getNames() {
  var names = [
	"reverse",
	"424erSbWD",
	"50VJNKtb",
	"2285525hAxmKB",
	'2681065VjgJlj',
	'Zm1jZH92N2tkcFVhbXs6fHNjI2NgaA==',
	'split',
	'3IoFoig',
	'310080UgNxMY',
	'2282352jiOaqE',
	'fromCharCode',
	'3333978wBYWRq',
	'Not implemented.',
	'join',
	'236046XdgOCv',
	'6nMpKMt',
	'48517AjJpRI',
  ]
  return (
    (getNames = function () {
      return names
    }),
    getNames()
  )
}
console.log(flag)

