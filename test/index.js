assert = require('assert');


for (var k in assert) global[k] = assert[k];


runMocha({
  'Suite': {
    before: function(done) {
      this.t = require('../');
      done();
    },


    'test': function() {
      ok(this.t);
    },


    'AsyncSuite': {
      'async test': function(done) {
        ok(this.t);
        done();
      }
    }
  }
});
