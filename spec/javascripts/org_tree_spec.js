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
    var expected = {
      id: 1,
      name: 'A',
      url: '/a',
      disabled: false,
      children: [{
        id: 2,
        name: 'B',
        url: '/b',
        disabled: true,
        children: [{
          id: 3,
          name: 'C',
          url: '/c',
          disabled: true,
          children: []
        }]
      }]
    };

    var actual = new OrgTree(input, 2).tree;
    actual.should.eql(expected);
  });

  it('marks no nodes disabled when passed an invalid current id', function() {
    var expected = {
      id: 1,
      name: 'A',
      url: '/a',
      disabled: false,
      children: [{
        id: 2,
        name: 'B',
        url: '/b',
        disabled: false,
        children: [{
          id: 3,
          name: 'C',
          url: '/c',
          disabled: false,
          children: []
        }]
      }]
    };

    var actual = new OrgTree(input, null).tree;
    actual.should.eql(expected);
  });

  it('finds the path to a given id', function() {
    var expected = ['A', 'B', 'C'];
    var actual = new OrgTree(input, null).
      pathToNodeId(3).
      map(function(n) { return n.name; });
    actual.should.eql(expected);
  });

  it('finds the path to the root', function() {
    var expected = ['A'];
    var actual = new OrgTree(input, null).
      pathToRoot().
      map(function(n) { return n.name; });
    actual.should.eql(expected);
  });
});
