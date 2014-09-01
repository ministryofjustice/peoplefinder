//= require spec_helper
//= require org_tree

describe('OrgTree', function() {
  var input = {
    id: 1,
    name: 'A',
    url: '/a',
    children: [{
      id: 2,
      name: 'B',
      url: '/b',
      children: [{
        id: 3,
        name: 'C',
        url: '/c',
        children: []
      }]
    }]
  };

  it('marks nodes including and below current disabled', function() {
    var actual = new OrgTree(input, 2).tree;
    expect(actual.disabled).to.be.false;
    expect(actual.children[0].disabled).to.be.true;
    expect(actual.children[0].children[0].disabled).to.be.true;
  });

  it('marks no nodes disabled when passed an invalid current id', function() {
    var actual = new OrgTree(input, null).tree;
    expect(actual.disabled).to.be.false;
    expect(actual.children[0].disabled).to.be.false;
    expect(actual.children[0].children[0].disabled).to.be.false;
  });

  it('finds the path to a given id', function() {
    var expected = ['A', 'B', 'C'];
    var actual = new OrgTree(input, null).
      pathToNodeId(3).
      map(function(n) { return n.name; });
    expect(actual).to.eql(expected);
  });

  it('finds the path to the root by id', function() {
    var expected = ['A'];
    var actual = new OrgTree(input, null).
      pathToNodeId(1).
      map(function(n) { return n.name; });
    expect(actual).to.eql(expected);
  });

  it('finds the path to the root for no id', function() {
    var expected = ['A'];
    var actual = new OrgTree(input, null).
      pathToNodeId(null).
      map(function(n) { return n.name; });
    expect(actual).to.eql(expected);
  });
});
