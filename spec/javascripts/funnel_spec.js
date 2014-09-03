//= require spec_helper
//= require funnel

var ga = function(){};

describe('Funnel', function(){

    describe('init', function(){
        it('defaults to a naming scope of pf is none is passed', function(){
           var funnel = Funnel.init();
            expect(funnel.attrScope).to.equal('pf')
        });
        it('takes a naming scope to append to data attr lookups', function(){
            var funnel = Funnel.init('sm');
            expect(funnel.attrScope).to.equal('sm');
        });
        it('should be possible to pass in a source dom to work on', function(){
            var funnel = Funnel.init('sm');
            expect(funnel.source).to.not.equal(null);
        });
    });
    describe('splitDataArgs', function(){
        it('splits comma seperated attributes found in a data attr value into an array', function(){
            fixture.load('data');
            expect(Funnel.splitDataArgs('.pf-funnel')).to.deep.include.members([ 'innee', 'meenee', 'minee', 'mo' ]);
        });
    });
    describe('sendPageView', function(){
       it('calls ga and sends the value of the data-pf-pageview attr', function(){
           fixture.load('ga');
           var funnel = Funnel.init('pf');
           var gaSpy = sinon.spy(window, 'ga');
           funnel.update();
           expect(gaSpy.getCall(0).args[0]).to.equal('send');
           expect(gaSpy.getCall(0).args[1]).to.equal('/profile/edit_success');
           window.ga.restore();
       });
    });
    describe('sendPageEvent', function(){
        it('calls ga with the value of the data-pf-event attr', function(){
            fixture.load('data');
            var funnel = Funnel.init('pf');
            var spy = sinon.spy(window, 'ga');
            funnel.update();
            expect(spy.calledOnce).to.equal(true);
        });
    });
});