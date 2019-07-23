window.onload = function () {
  var app = new Vue({
    el: '#uam',
    data: {
      t: null,
      step: 0,
      phone: '',
      at: null,
      error: null,
      online: false,
      response: {}
    },
    mounted() {
      this.t = window.pt
      this.step = window.pt.step
      this.phone = window.pt.phone
      this.call_to = window.pt.call_to
      this.login_button =  window.pt.login_button
    },

  created: function () {
    this.debouncedphonerewrite = debounce(this.phonerewrite, 500)
  },

  watch: {
    phone: function (newQ, oldQ) {
      this.debouncedphonerewrite()
    }
  },


    methods: {

      phonerewrite: function () {

        var ti = this.phone
            .replace(/[^\d+]/g,'')
            .replace(/^89/g,'+79')
            .replace(/^79/g,'+79')
            .replace(/^9/g,'+79')
            .replace(/^(02)([459])/g,'+3752$2') //belarus
            .replace(/^033/g,'+37533')
            .replace(/^044/g,'+37544')
            .replace(/^7([04567])/g,'+77$1') //kazahstan
            ;

         if (ti!=this.phone) {
           this.phone = ti
         }
       },


      check: function (challenge) {
             this.challenge(null, null, challenge);
      },

      login: function (data) {
        var cbname = 'callback'
        if (data.nastype == "routeros") {
          cbname = 'var'
        }
        
        console.log({url:data.linklogin, params: data.para, adapter: axiosJsonpAdapter, callbackParamName: cbname })
        
        var self = this;
        
        axios({url:data.linklogin, params: data.para, adapter: axiosJsonpAdapter, callbackParamName: cbname }).then(
            function (r) {
              console.log(r)
              self.step = 'status'
              
              if (r.data.error) {
                self.error = r.data.error
              }
              
              if (r.data.clientState == 1 || r.data.clientState == "yes") {
                self.online = true
              }
              
              self.logout_url = r.data.redir.logoutURL.replace('/jsonp/','/')
              
              if (r.data.redir.redirectionURL && self.online) {
                if (r.data.redir.redirectionURL.match(/status$/g) ) {
                  self.step = 'status'
                } else {
                   
                   setTimeout(function(){window.location.replace(r.data.redir.originalURL);},10)
                   if ( r.data.redir.redirectionURL != r.data.redir.originalURL ) {
                        var win = window.open(r.data.redir.redirectionURL, '_blank');
                        win.focus();
                   }
                }
              }
            }
        )
      
      },

      challenge: function (at,phone, challenge) {
        var self = this;
        this.at = at;
        
        data = {}
        
        if (at) {
          data.id=at.id
          data.type= at.type          
        }
        
        if (phone) {
          data.phone= phone
        } 

        if (challenge) {
          data.challenge=challenge
        } 
        
        axios.post('/uam/challenge/', data).then(
          function (r) {
            console.log(r)
            if (r.data.call_to) {
              self.step='call_to',
              self.call_to = r.data.call_to
            }
            if (r.data.linklogin) {
              self.step='login'
              self.response = r.data
              if (self.login_button==false)
                self.login(r.data)
            }
          }
        )
      }
    }
  })
}
